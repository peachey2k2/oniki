using System.Threading.Tasks;
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
	[Export] public double delay = 0.1;

	public override async Task _spawn(){
		float gap = Mathf.Pi * 2 / amount;
        float speed = bullet.speed;
		Vector2 direction = Vector2.Right;
        for (int i = 0; i < repeat; i++){
            for (int j = 0; j < amount; j++){
                if (stop_flag) return;
                spawn_bullet(
                    real_pos +  direction * distance,
                    direction.Angle(),
					speed
                );
                direction = direction.Rotated(gap);
            }
            direction = direction.Rotated(tilt_rad);
			await ToSignal(STGGlobal.GetTree().CreateTimer(delay, false), "timeout");
        }
	}
}