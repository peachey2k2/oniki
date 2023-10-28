using Godot;
using Godot.Collections;
using GodotSTG;

namespace GodotSTG;

[GlobalClass]
public partial class STGStats:Resource{
    [Export] public Vector2 player_position {get; set;}
    [Export] public Array<STGBar> bars {get; set;} = new();
}