using Godot;
using GodotSTG;
using Godot.Collections;
using System;

[GlobalClass, Icon("res://addons/GodotSTG/icons/battlecontroller.png")]
public partial class BattleController:Node2D{
    private static STGGlobal STGGlobal;
    [ExportCategory("BattleController")]
    [Export] private STGStats stats {get; set;}

    public int life;
    public STGSpell.Shield shield_state;
    public SceneTree tree;
    public Timer timer;
    public bool is_spell_over;
    public int flag;

    public int hp_threshold;
    public int time_threshold;

    public CollisionObject2D player;
    public CollisionObject2D enemy;
    Rect2 arena_rect;
    string signals_are_hard;

    public override void _Ready(){
        STGGlobal = STGGlobal.Instance;

        tree = GetTree();
        timer = new(){OneShot = true};
        STGGlobal.end_sequence += _on_end_sequence;
        timer.Timeout += _on_spell_timed_out;
        STGGlobal.bar_emptied += _on_bar_emptied;
        STGGlobal.damage_taken += _on_damage_taken;
        AddChild(timer);
    }

    public async void start(){
        GodotSTG.Debug.Assert(player != null, "\"player\" has to be set in order for start() to work.");
        GodotSTG.Debug.Assert(enemy != null, "\"enemy\" has to be set in order for start() to work.");
        // GodotSTG.Debug.Assert(arena_rect != null, "\"arena_rect\" has to be set in order for start() to work.");
        STGGlobal.clear();
        STGGlobal.shared_area.Reparent(this, false);
        STGGlobal.controller = this;
        STGGlobal.EmitSignal("battle_start");
        STGGlobal.arena_rect = arena_rect;
        int bar_count = stats.bars.Count;
        STGGlobal.EmitSignal("bar_changed", bar_count);
        life = 0;
        player.Position = STGGlobal.lerp4arena(stats.player_position);
        foreach (STGBar curr_bar in stats.bars){
            emit_life(curr_bar);
            foreach (STGSpell curr_spell in curr_bar.spells){
                is_spell_over = false;
                enemy.Position = STGGlobal.lerp4arena(curr_spell.enemy_pos);
                change_shield(curr_spell.shield);
                timer.WaitTime = curr_spell.time;
                timer.Start();
                STGGlobal.EmitSignal("spell_name_changed");
                // enemy.Monitoring = true;
                cache_spell_textures(curr_spell);
                flag += 1; // timer await is encapsulated in flag increments and decrements
                await ToSignal(GetTree().CreateTimer(curr_spell.wait_before, false), "timeout");
                flag -= 1; // to prevent running multiple instances at the same time
                if (flag > 0) return;
                while (!is_spell_over){
                    foreach (STGSequence curr_sequence in curr_spell.sequences){
                        if (is_spell_over) break;
                        hp_threshold = curr_sequence.end_at_hp;
                        time_threshold = curr_sequence.end_at_time;
                        curr_sequence.spawn_sequence();
                        flag += 1; // timer await is encapsulated in flag increments and decrements
                        await ToSignal(STGGlobal, "end_sequence"); //
                        await ToSignal(GetTree().CreateTimer(curr_spell.wait_between, false), "timeout");
                        flag -= 1; // to prevent running multiple instances at the same time
                        if (flag > 0) return;
                    }
                    if ((curr_spell.sequence_flags&2) == 0) break;
                }
                await ToSignal(STGGlobal, "end_spell");
                GC.Collect();
                // enemy.Monitoring = false;
            }
            bar_count -= 1;
            STGGlobal.EmitSignal("bar_changed", bar_count);
        }
        STGGlobal.EmitSignal("end_battle");
    }

    public void cache_spell_textures(STGSpell spell){
        foreach (STGSequence seq in spell.sequences){
            foreach (STGSpawner spw in seq.spawners){
                STGBulletModifier blt = spw.bullet;
                while (true){
                    STGGlobal.create_texture(blt);
                    if (blt.next == null) break;
                    blt = blt.next;
                }
            }
        }
    }

    public async void kill(){
        ProcessMode = ProcessModeEnum.Disabled;
        STGGlobal.shared_area.Reparent(STGGlobal, false);
        STGGlobal.EmitSignal("stop_spawner");
        STGGlobal.clear();
        QueueRedraw();
        await ToSignal(STGGlobal, "cleared");
        QueueFree();
    }

    public override void _PhysicsProcess(double delta){
        QueueRedraw();
    }

    public override void _Draw(){
        foreach (STGBulletData blt in STGGlobal.blts){
            DrawTexture(blt.texture, blt.position - blt.texture.GetSize() * (float)0.5);
        }
    }

    public void emit_life(STGBar _bar){
        Array<int> values = new();
        Array<Color> colors = new();
        foreach (STGSpell i in _bar.spells){
            values.Add(i.health);
            colors.Add(i.bar_color);
        }
        STGGlobal.EmitSignal("life_changed", values, colors);
    }

    public void change_shield(STGSpell.Shield _shield){
        shield_state = _shield;
        STGGlobal.EmitSignal("shield_changed", (int)_shield);
    }

    public void _on_timer_timeout(){

    }

    public void _on_bar_emptied(){
        is_spell_over = true;
        STGGlobal.EmitSignal("end_sequence");
        STGGlobal.EmitSignal("end_spell");
        STGGlobal.EmitSignal("stop_spawner");
    }

    public void _on_spell_timed_out(){
        is_spell_over = true;
        STGGlobal.EmitSignal("end_sequence");
        STGGlobal.EmitSignal("end_spell");
        STGGlobal.EmitSignal("stop_spawner");
    }

    public void _on_end_sequence(){
        STGGlobal.EmitSignal("stop_spawner");
    }

    public void _on_damage_taken(int _life){
        if (life > hp_threshold) return;
        STGGlobal.EmitSignal("end_sequence");
        STGGlobal.EmitSignal("stop_spawner");
    }
}
