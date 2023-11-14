using System;
using System.Diagnostics;
using System.Threading.Tasks;
using Godot;
using GodotSTG;

namespace GodotSTG;

[GlobalClass]
public partial class STGSpawner:Resource{
    
    public static STGGlobal STGGlobal;
    public static SceneTree tree;
    public enum PosType{Absolute, Relative}
    public enum Towards{Generic, Player}

    [ExportGroup("Spawner")]
    [Export] public Vector2 position {get; set;}
    [Export] public PosType position_type {get; set;}
    [Export] public Towards towards {get; set;}
    [Export] public float rotation_speed {get; set;}

    [ExportGroup("Bullet")]
    [Export] public STGBulletModifier bullet {get; set;}

    public Vector2 real_pos;
    public bool stop_flag;
    public bool is_running;

    public STGBulletData bdata;
    public Texture2D tex;

    public async void spawn(){
        STGGlobal = STGGlobal.Instance;
        tree = STGGlobal.GetTree();
        
        if (is_running) return;
        is_running = true;
        stop_flag = false;
        bdata = STGGlobal.bltdata[bullet.index];
        tex = STGGlobal.textures[bullet.id];
        if (position_type == PosType.Relative){
            real_pos = STGGlobal.lerp4arena(position) + STGGlobal.controller.enemy.Position;
        } else {
            real_pos = STGGlobal.lerp4arena(position);
        }
        STGGlobal.stop_spawner += _stop_spawner;
        await _spawn();
        STGGlobal.Instance.EmitSignal("spawner_done");
    }

    public async virtual Task _spawn(){
        Debug.Assert(false, "No \"_spawn()\" found.");
        return;
    }

    public void _stop_spawner(){
        stop_flag = true;
        is_running = false;
    }

    public void spawn_bullet(Vector2 pos, float dir, float mag){
        STGBulletData _bdata = (STGBulletData)bdata.Duplicate();
        _bdata.current = 0;
        _bdata.position = pos;
        _bdata.direction = dir;
        _bdata.magnitude = mag;
        _bdata.lifespan = bullet.lifespan;
        _bdata.texture = tex;
        _bdata.next = bullet.next;
        _bdata.tweens = bullet.tweens;
        // _bdata.tween = tree.CreateTween();
        // foreach (BulletTween tw in bullet.tweens){
        //     _bdata.tween.TweenProperty(_bdata, tw.Property, tw.FinalValue + (tw.Additive ? (float)_bdata.Get(tw.Property) : 0), tw.Duration).SetTrans(tw.Transition);
        //     if (tw.Easing >= 0) _bdata.tween.SetEase((Tween.EaseType)tw.Easing);
        //     if (tw.Parallelize) _bdata.tween.Parallel();
        // }
        STGGlobal.create_bullet(_bdata);
    }
}