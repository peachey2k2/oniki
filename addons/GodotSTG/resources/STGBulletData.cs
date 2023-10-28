using Godot;
using GodotSTG;

[GlobalClass]
public partial class STGBulletData:Resource{

    [Export] public Texture2D texture;
    [Export] public float collision_radius;

    public Vector2 position;
    public Vector2 velocity;
    public Vector2 acceleration;
    public float lifespan;

    public STGShape shape;
}