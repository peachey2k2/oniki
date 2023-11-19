using Godot;
using GodotSTG;
using Godot.Collections;
using System;
using System.Threading.Tasks;

[GlobalClass, Icon("res://addons/GodotSTG/assets/battlecontroller.png")]
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
        STGGlobal.EmitSignal(STGGlobal.SignalName.battle_start);
        STGGlobal.arena_rect = arena_rect;
        int bar_count = stats.bars.Count;
        STGGlobal.EmitSignal(STGGlobal.SignalName.bar_changed, bar_count);
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
                STGGlobal.EmitSignal(STGGlobal.SignalName.spell_name_changed);
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
                        await ToSignal(STGGlobal, STGGlobal.SignalName.end_sequence); //
                        await ToSignal(GetTree().CreateTimer(curr_spell.wait_between, false), "timeout");
                        flag -= 1; // to prevent running multiple instances at the same time
                        if (flag > 0) return;
                        if ((curr_spell.sequence_flags&4) == 4) STGGlobal.clear();
                    }
                    if ((curr_spell.sequence_flags&2) == 0) break;
                }
                await ToSignal(STGGlobal, STGGlobal.SignalName.end_spell);
                GC.Collect(); // force collect to prevent future lag spikes
                // enemy.Monitoring = false;
            }
            bar_count -= 1;
            STGGlobal.EmitSignal(STGGlobal.SignalName.bar_changed, bar_count);
        }
        STGGlobal.EmitSignal(STGGlobal.SignalName.end_battle);
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
        STGGlobal.EmitSignal(STGGlobal.SignalName.stop_spawner);
        STGGlobal.clear();
        QueueRedraw();
        await ToSignal(STGGlobal, STGGlobal.SignalName.cleared);
        QueueFree();
    }

    public override void _PhysicsProcess(double delta){
        QueueRedraw();
    }

    public override void _Draw(){
        // Parallel.ForEach(STGGlobal.blts, blt => {
        //     DrawSetTransform(blt.position, blt.direction);
        //     DrawTexture(blt.texture, -blt.texture.GetSize() / 2);
        // }); NOTE TO SELF: DO NOT PARALLELIZE THIS. JUST DON'T.
        foreach (STGBulletData blt in STGGlobal.blts){
            DrawSetTransform(blt.position, blt.direction);
            DrawTexture(blt.texture, -blt.texture.GetSize() / 2);
        }
        DrawSetTransform(Vector2.Zero, 0);
        foreach (STGBulletData blt in STGGlobal.brem){
            DrawTexture(blt.texture, blt.position - blt.texture.GetSize() * (float)0.5, new Color(1, 1, 1, (float)blt.lifespan * 2));
        }
    }

    public void emit_life(STGBar _bar){
        Array<int> values = new();
        Array<Color> colors = new();
        foreach (STGSpell i in _bar.spells){
            values.Add(i.health);
            colors.Add(i.bar_color);
        }
        STGGlobal.EmitSignal(STGGlobal.SignalName.life_changed, values, colors);
    }

    public void change_shield(STGSpell.Shield _shield){
        shield_state = _shield;
        STGGlobal.EmitSignal(STGGlobal.SignalName.shield_changed, (int)_shield);
    }

    public void _on_timer_timeout(){

    }

    public void _on_bar_emptied(){
        is_spell_over = true;
        STGGlobal.EmitSignal(STGGlobal.SignalName.end_sequence);
        STGGlobal.EmitSignal(STGGlobal.SignalName.end_spell);
        STGGlobal.EmitSignal(STGGlobal.SignalName.stop_spawner);
    }

    public void _on_spell_timed_out(){
        is_spell_over = true;
        STGGlobal.EmitSignal(STGGlobal.SignalName.end_sequence);
        STGGlobal.EmitSignal(STGGlobal.SignalName.end_spell);
        STGGlobal.EmitSignal(STGGlobal.SignalName.stop_spawner);
    }

    public void _on_end_sequence(){
        STGGlobal.EmitSignal(STGGlobal.SignalName.stop_spawner);
    }

    public void _on_damage_taken(int _life){
        if (life > hp_threshold) return;
        STGGlobal.EmitSignal(STGGlobal.SignalName.end_sequence);
        STGGlobal.EmitSignal(STGGlobal.SignalName.stop_spawner);
    }
}
