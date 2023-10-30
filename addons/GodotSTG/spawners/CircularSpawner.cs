using System.Runtime.InteropServices;
using Godot;

namespace GodotSTG;

[GlobalClass]
public partial class CircularSpawner:STGSpawner{
	[ExportGroup("Pattern")]
	private double _init_angle;
	public double init_angle_rad;
	[Export] public double init_angle{
		get { return _init_angle; }
		set{
			init_angle_rad = Mathf.DegToRad(value);
            _init_angle = value;
		}
	}
	[Export] public int amount = 5;
	[Export] public int repeat = 5;
	private double _tilt;
	public float tilt_rad;
	[Export] public double tilt{
		get{ return _tilt; }
		set{
			tilt_rad = (float)Mathf.DegToRad(value);
			_tilt = value;
		}
	}
	[Export] public float distance;
	[Export] public float stretch = 1;
	[Export] public double delay = 0.1;

	public override async void _spawn(){
		float gap = Mathf.Pi * 2 / amount;
        Vector2 velocity = bullet.speed * new Vector2((float)Mathf.Cos(init_angle_rad), (float)Mathf.Sin(init_angle_rad));
        for (int i = 0; i < repeat; i++)
        {
            for (int j = 0; j < amount; j++)
            {
                Vector2 velocity_normalized = velocity.Normalized();
                if (stop_flag) return;
                spawn_bullet(
                    real_pos + velocity_normalized * distance,
                    new Vector2(velocity.X, velocity.Y * stretch),
                    velocity_normalized * bullet.acceleration
                );
                velocity = velocity.Rotated(gap);
            }
            velocity = velocity.Rotated(tilt_rad);
			await ToSignal(STGGlobal.GetTree().CreateTimer(delay, false), "timeout");
        }
	}
}