using Godot;
using Godot.Collections;
using GodotSTG;


namespace GodotSTG;

[GlobalClass]
public partial class STGBar:Resource{
    [Export] public Array<STGSpell> spells {get; set;} = new();
}