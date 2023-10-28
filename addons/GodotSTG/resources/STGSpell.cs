using Godot;
using Godot.Collections;
using GodotSTG;

namespace GodotSTG;

[GlobalClass]
public partial class STGSpell:Resource{
    public enum Shield{None, Red}
    public enum Movement{Static, Random}

    [Export] public string name {get; set;}
    [Export] public int health {get; set;}
    [Export] public int time {get; set;}
    [Export] public Color bar_color {get; set;} = Colors.White; // WHY IS IT COLORS AND NOT COLOR???
    [Export] public Vector2 enemy_pos {get; set;}
    [Export] public Movement enemy_movement {get; set;}
    [Export] public Shield shield {get; set;}
    [Export] public bool randomize_sequences {get; set;} = false;
    [Export] public Array<STGSequence> sequences {get; set;} = new();
}