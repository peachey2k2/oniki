using Godot;

namespace GodotSTG;

public partial class STGCustomData:Resource{
    public enum ShieldType{
        None,
        Ghost,
        Red,
    }
    [Export] public Color bar_color {get; set;} = Colors.White; // WHY IS IT COLORS AND NOT COLOR???
    [Export] public ShieldType shield_type {get; set;} = ShieldType.None;
} 