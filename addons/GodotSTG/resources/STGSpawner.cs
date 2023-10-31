using System;
using System.Diagnostics;
using Godot;
using GodotSTG;

namespace GodotSTG;

[GlobalClass]
public partial class STGSpawner:Resource{
    
    public static STGGlobal STGGlobal;
    public enum PosType{Absolute, Relative}
    public enum Towards{Generic, Player}

    [ExportGroup("Spawner")]
    [Export] public Vector2 position {get; set;}
    [Export] public PosType position_type {get; set;}
    [Export] public Towards towards {get; set;}
    [Export] public float rotation {get; set;}
    [Export] public float rotation_speed {get; set;}

    [ExportGroup("Bullet")] 
    [Export] public STGBulletModifier bullet {get; set;}

    public Vector2 real_pos;
    public bool stop_flag;
    public bool is_running;

    public STGBulletData bdata;
    public Texture2D tex;

    public void spawn(){
        STGGlobal = STGGlobal.Instance;

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
        _spawn();
    }

    public virtual void _spawn(){
        Debug.Assert(false, "No \"_spawn()\" found.");
    }

    public void _stop_spawner(){
        stop_flag = true;
        is_running = false;
    }

    public void spawn_bullet(Vector2 pos, Vector2 vel, Vector2 acc){
        STGBulletData _bdata = (STGBulletData)bdata.Duplicate();
        _bdata.position = pos;
        _bdata.velocity = vel;
        _bdata.acceleration = acc;
        _bdata.lifespan = bullet.lifespan;
        _bdata.texture = tex;
        _bdata.next = bullet.next;
        STGGlobal.create_bullet(_bdata);
    }
}