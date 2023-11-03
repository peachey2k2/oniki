using Godot;
using Godot.Collections;
using GodotSTG;

namespace GodotSTG;

[GlobalClass]
public partial class STGSequence:Resource{
    
    // [Export] public float wait_before {get; set;} = 1;
    [Export] public int end_at_hp {get; set;} = -1;
    [Export] public int end_at_time {get; set;} = -1;
    [Export] public bool persist {get; set;} = false;
    [Export] public Array<STGSpawner> spawners {get; set;} = new();
    public async void spawn_sequence(){
        foreach (STGSpawner spw in spawners){
            spw.spawn();
        }
        await ToSignal(STGGlobal.Instance, "spawner_done");
        STGGlobal.Instance.EmitSignal("end_sequence");
    }

}
