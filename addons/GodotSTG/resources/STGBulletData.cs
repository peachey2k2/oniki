using System.Transactions;
using Godot;
using Godot.Collections;
using GodotSTG;

[GlobalClass, Icon("res://addons/GodotSTG/assets/bulletdata.png")]
public partial class STGBulletData:Resource{

    [Export] public Texture2D texture;
    [Export] public float collision_radius;

    public Vector2 position;
    public float direction;
    public float magnitude;
    public double lifespan;
    public Array<STGTween> tweens;
    public int current = 0;

    public STGShape shape;
    public STGBulletModifier next;
}