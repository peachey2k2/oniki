using Godot;

namespace GodotSTG;

[GlobalClass]
public partial class STGBulletModifier:Resource{

    [Export] public int index {get; set;} = 0;
    [Export] public Color outer_color {get; set;} = Colors.Red;
    [Export] public Color inner_color {get; set;} = Colors.White;
    [Export] public float speed {get; set;}
    [Export] public Vector2 acceleration {get; set;}
    [Export] public double lifespan {get; set;} = -1;
    [Export] public float sine_freq {get; set;}
    [Export] public float sine_width {get; set;}
    [Export] public STGBulletModifier next {get; set;}

    // this is automatically set at runtime. dw about it.
    public int id = -1;
}
