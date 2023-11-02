using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using Godot;
using Godot.Collections;
using GodotSTG;

public partial class STGGlobal:Node{
    [Signal] public delegate void battle_startEventHandler();
    [Signal] public delegate void shield_changedEventHandler(int value);
    [Signal] public delegate void spell_name_changedEventHandler(string value);
    [Signal] public delegate void bar_changedEventHandler(int value);
    [Signal] public delegate void life_changedEventHandler(Array<int> values, Array<Color> colors);
    [Signal] public delegate void end_sequenceEventHandler();
    [Signal] public delegate void end_spellEventHandler();
    [Signal] public delegate void end_battleEventHandler();
    [Signal] public delegate void stop_spawnerEventHandler();
    [Signal] public delegate void clearedEventHandler();
    [Signal] public delegate void spawner_doneEventHandler();

    [Signal] public delegate void bar_emptiedEventHandler();
    [Signal] public delegate void damage_takenEventHandler(int new_amount);

    private PackedScene zone_template;
    private PackedScene area_template;

    public BattleController controller {get; set;}

    System.Collections.Generic.Dictionary<string, Variant>[] settings = {
        new() {
            {"name", "bullet_directory"},
            {"default", "res://addons/GodotSTG/bullets/"},
        },
        new() {
            {"name", "collision_layer"},
            {"default", 0b10},
        },
        new() {
            {"name", "pool_size"},
            {"default", 5000},
        },
        new() {
            {"name", "removal_margin"},
            {"default", 100},
        }
    };

    // settings
    public string BULLET_DIRECTORY;
    public uint COLLISION_LAYER;
    public uint POOL_SIZE;
    public uint REMOVAL_MARGIN;

    // low level tomfuckery
    public List<STGBulletData> blts = new();
    public List<STGShape> bpool = new();
    public List<STGBulletData> bqueue = new();
    public List<STGBulletData> bltdata = new(); // using new() here crashes the game with no debug message. why???
    public List<Texture2D> textures = new();
    private Area2D _shared_area;
    public Area2D shared_area {
        get{ return _shared_area; }
        set{
            area_rid = value.GetRid();
            _shared_area = value;
            shared_area.CollisionLayer = COLLISION_LAYER;
        }
    }
    public Rid area_rid;
    private Rect2 _arena_rect;
    public Rect2 arena_rect {
        get{ return _arena_rect; }
        set{
            _arena_rect = value;
            arena_rect_margined = value.Grow(REMOVAL_MARGIN);
        }
    }
    public Rect2 arena_rect_margined {get; set;}
    public int bullet_count {get; set;} = 0;

    // clocks
    const float TIMER_START = 10000000;
    public float clock;
    public float clock_real;
    public SceneTreeTimer clock_timer;
    public SceneTreeTimer clock_real_timer;

    public bool exiting = false;
    public static STGGlobal Instance { get; private set; }

    public STGGlobal(){
        foreach (System.Collections.Generic.Dictionary<String, Variant> _setting in settings){
            Set(((string)_setting["name"]).ToUpper(), ProjectSettings.GetSetting("godotstg/" + _setting["name"], _setting["default"]));
        }
    }

    public override async void _Ready(){
        Instance = this; // epic self-reference to access the singleton from everywhere

        // there is no @onready in c# :sadge: 
        area_template = (PackedScene)ResourceLoader.Load("res://addons/GodotSTG/resources/shared_area.tscn");

        foreach (string file in DirAccess.GetFilesAt(BULLET_DIRECTORY)){
            bltdata.Add((STGBulletData)ResourceLoader.Load((BULLET_DIRECTORY + "/" + file).TrimSuffix(".remap"))); // builds use .remap extension so that is trimmed here
            // you can look at this issue for more info: https://github.com/godotengine/godot/issues/66014
            // also this will probably change in a later release for the engine

        // pooling lol
        shared_area = (Area2D)area_template.Instantiate(); // THIS MOTHERFUCKER...
        AddChild(shared_area);
        // await ToSignal(GetTree().CreateTimer(5), "timeout");
        for (int i = 0; i < POOL_SIZE; i++){
            Rid shape_rid = PhysicsServer2D.CircleShapeCreate();
            PhysicsServer2D.AreaAddShape(area_rid, shape_rid);
	    	PhysicsServer2D.AreaSetShapeDisabled(area_rid, i, true);
            bpool.Add(new STGShape(shape_rid, i));
        }
        await ToSignal(GetTree().CreateTimer(1), "timeout");
        }
        // global clocks cuz yeah
        clock_timer      = GetTree().CreateTimer(TIMER_START, false);
        clock_real_timer = GetTree().CreateTimer(TIMER_START, true);
    }

    // i got the idea on how to optimize this from this nice devlog. it's pretty clean and detailed.
    // also their game looks pretty cool too, so check it out if you have the time.
    // https://worldeater-dev.itch.io/bittersweet-birthday/devlog/210789/howto-drawing-a-metric-ton-of-bullets-in-godot
    public void create_bullet(STGBulletData data){
        GodotSTG.Debug.Assert(bpool.Count > 0, "Pool is out of bullets.");
        STGShape shape = bpool.Last();
        GodotSTG.Debug.Assert(shape.rid.IsValid, "Shape RID is invalid.");
        bpool.RemoveAt(bpool.Count - 1);
        Transform2D t = new(0, data.position){Origin = data.position};
        data.shape = shape;
        PhysicsServer2D.AreaGetShape(area_rid, shape.idx);
        PhysicsServer2D.ShapeSetData(shape.rid, data.collision_radius);
        PhysicsServer2D.AreaSetShapeTransform(area_rid, shape.idx, t);
        PhysicsServer2D.AreaSetShapeDisabled(area_rid, shape.idx, false);
        if (data.lifespan <= 0) data.lifespan = 999999;
        blts.Add(data);
    }

    public STGBulletData configure_bullet(STGBulletData data){
        STGBulletModifier mod = data.next;
        data.velocity = data.velocity.Normalized() * mod.speed;
        data.acceleration = data.acceleration.Normalized() * mod.acceleration;
        data.lifespan = mod.lifespan > 0 ? mod.lifespan : 999999;
        data.texture = textures[mod.id];
        data.next = mod.next;
        return data;
    }

    // processing the bullets here.
    public override void _PhysicsProcess(double delta){
        float fdelta = (float)delta;
        bqueue.Clear();
        for (int i = 0; i < blts.Count; i++){
            STGBulletData blt = blts[i];
            if (blt.lifespan >= 0) blt.lifespan -= delta;
            else bqueue.Add(blt);
            blt.velocity += blt.acceleration * fdelta / 2;
            blt.position += blt.velocity * fdelta;
            blt.velocity += blt.acceleration * fdelta / 2;
            Transform2D t = new(0, blt.position){Origin = blt.position};
            if (!arena_rect_margined.HasPoint(blt.position)){
                bqueue.Add(blt);
                blt.next = null;
            }
    		PhysicsServer2D.AreaSetShapeTransform(area_rid, blt.shape.idx, t);
        }
        iterate_bullets();
    }

    public void create_texture(STGBulletModifier mod){
        if (mod.id != -1) return; // #todo: also check whether this exact texture is already saved (same index and colors)
        Texture2D tex = (Texture2D)bltdata[mod.index].texture.Duplicate(); // lol
        if (tex is GradientTexture2D){
            GradientTexture2D gradientTex = tex as GradientTexture2D;
            gradientTex.Gradient = gradientTex.Gradient.Duplicate() as Gradient;
            gradientTex.Gradient.Colors = new[] {mod.inner_color, mod.inner_color, mod.outer_color, mod.outer_color, Colors.Transparent};
        }
        mod.id = textures.Count;
        textures.Add(tex);
    }

    public void iterate_bullets(){
        foreach (STGBulletData blt in bqueue){
        // for (int i = 0; i < bqueue.Count; i++){
        //     STGBulletData blt = bqueue[i];
            if (blt.next == null){
                PhysicsServer2D.AreaSetShapeDisabled(area_rid, blt.shape.idx, true);
                blts.Remove(blt);
                bpool.Add(blt.shape);
            } else {
               blts[blts.IndexOf(blt)] = configure_bullet(blt);
            }
        }
        bullet_count = blts.Count;
    }

    public void clear(){
        EmitSignal(SignalName.stop_spawner);
        foreach (STGBulletData blt in blts){
            PhysicsServer2D.AreaSetShapeDisabled(area_rid, blt.shape.idx, true);
            bpool.Add(blt.shape);
        }
        blts.Clear();
        EmitSignal(SignalName.cleared);
    }

    public Vector2 lerp4arena(Vector2 weight){
        return new Vector2(
            Mathf.Lerp(arena_rect.Position.X, arena_rect.End.X, weight.X),
            Mathf.Lerp(arena_rect.Position.Y, arena_rect.End.Y, weight.Y)
        );
    }

    public override void _Notification(int what){
        if (what == NotificationWMCloseRequest && !exiting) exit();
    }

    public void exit(){
        exiting = true;
        //this leaks at exit. memory management is hard. sorry. #todo: fix
        GetTree().Paused = true;
        for (int i = PhysicsServer2D.AreaGetShapeCount(area_rid); i > -1; i--){
            PhysicsServer2D.FreeRid(PhysicsServer2D.AreaGetShape(area_rid, i));
        }
        GD.Print("Exited.");
        GetTree().Quit();
    }

    // this will always return how much time has passed since the game started.
    public float time(bool count_pauses = true){
        if (count_pauses) {return (float)(TIMER_START - clock_real_timer.TimeLeft);}
        else              {return (float)(TIMER_START - clock_timer.TimeLeft);}
    }

}