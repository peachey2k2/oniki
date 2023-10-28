using Godot;
using Godot.Collections;
using GodotSTG;

namespace GodotSTG;

[GlobalClass]
public partial class STGSequence:Resource{
    
    [Export] public float wait_before {get; set;} = 1;
    [Export] public int end_at_hp {get; set;} = -1;
    [Export] public int end_at_time {get; set;} = -1;
    [Export] public bool clear_after_done {get; set;} = true;
    [Export] public Array<STGSpawner> spawners {get; set;} = new();

}
