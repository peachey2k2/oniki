using Godot;
using GodotSTG;

namespace GodotSTG;

[GlobalClass]
public partial class STGShape:Resource{
    public Rid rid;
    public int idx;

    public STGShape(Rid rid, int idx){
        this.rid = rid;
        this.idx = idx;
    }
}