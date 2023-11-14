using Godot;
using Godot.Collections;

namespace GodotSTG;

[GlobalClass]
public partial class STGBulletModifier:Resource{

    [Export] public int index {get; set;} = 0;
    [Export] public Color outer_color {get; set;} = Colors.Red;
    [Export] public Color inner_color {get; set;} = Colors.White;
    [Export] public float speed {get; set;}
    public double lifespan {get; set;} = -1;
    [Export] public Array<STGTween> tweens = new();
    [Export] public STGBulletModifier next {get; set;}

    // this are automatically set at runtime. dw about it.
    public int id = -1;
}