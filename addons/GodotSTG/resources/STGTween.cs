using System.Collections.Generic;
using System.Diagnostics;
using System.Reflection;
using Godot;
using GodotSTG;

namespace GodotSTG;

[GlobalClass]
public partial class STGTween:Resource{
    public enum TweenProperty {magnitude, direction, homing}
    public enum TweenMode {Set, Add}
    public StringName property_str;
    private TweenProperty _property;
    [Export] public TweenProperty property{
        get{ return _property; }
        set{
            _property = value;
            property_str = value.ToString();
        }
    }
    [Export] public TweenMode mode;
    [Export] public float length;
    public List<float> list = new();
    private Curve _curve;
    [Export] public Curve curve{
        get{ return _curve; }
        set{
            _curve = value;
            float increment = 1 / (length * 60);
            for (float i = 0; i < 1; i += increment){
                list.Add(curve.Sample(i));
            }
        }
    }
}