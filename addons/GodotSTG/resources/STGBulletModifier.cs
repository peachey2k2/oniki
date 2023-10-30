using Godot;

namespace GodotSTG;

[GlobalClass]
public partial class STGBulletModifier:Resource{
    public enum Type{Low, Regular, High}
    public enum TriggerCheck{Exited, Entered}

    [Export] public int index {get; set;} = 0;
    [Export] public Color outer_color {get; set;} = Colors.Red;
    [Export] public Color inner_color {get; set;} = Colors.White;
    [Export] public Type type {get; set;} = Type.Regular;
    [Export] public float speed {get; set;}
    [Export] public Vector2 acceleration {get; set;}
    [Export] public double lifespan {get; set;} = -1;
    [Export] public float sine_freq {get; set;}
    [Export] public float sine_width {get; set;}
    [Export] public STGBulletModifier zoned {get; set;}
    [Export] public TriggerCheck trigger_check {get; set;} = TriggerCheck.Exited;

    // this is automatically set at runtime. dw about it.
    public int id = -1;
}
