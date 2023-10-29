#if TOOLS
using Godot;
using Godot.Collections;

[Tool]
public partial class plugin:EditorPlugin{

	Dictionary[] settings = {
		new(){
			{"name", "bullet_directory"},
			{"default", "res://addons/GodotSTG/bullets/"},
			{"type", (int)Variant.Type.String}, // int casting cuz appaerently 
			{"hint", (int)PropertyHint.Dir},    // enums aren't real.
			{"hint_string", ""}
		},
		new(){
			{"name", "collision_layer"},
			{"default", 0b10},
			{"type", (int)Variant.Type.Int},
			{"hint", (int)PropertyHint.Layers2DPhysics},
			{"hint_string", ""}
		},
		new(){
			{"name", "removal_margin"},
			{"default", 100},
			{"type", (int)Variant.Type.Int},
			{"hint", (int)PropertyHint.Range},
			{"hint_string", "0,1000,1,or_greater"}
		},
		new(){
			{"name", "pool_size"},
			{"default", 5000},
			{"type", (int)Variant.Type.Int},
			{"hint", (int)PropertyHint.Range},
			{"hint_string", "100,20000,1,or_greater"}
		}
	};

	public override void _EnterTree(){
		AddAutoloadSingleton("STGGlobal", "res://addons/GodotSTG/STGGlobal.cs");
		_setup_settings();
	}

	public override void _ExitTree(){
		RemoveAutoloadSingleton("STGGlobal");
	}

    public override void _DisablePlugin(){
        _clear_settings();
    }

	public void _setup_settings(){
		foreach (Dictionary _setting in settings){
			string _name = _get_setting_path(_setting);
			if (!ProjectSettings.HasSetting(_name)){
				var _default = _setting["default"];
				ProjectSettings.SetSetting(_name, _default);
				ProjectSettings.SetInitialValue(_name, _default);
				ProjectSettings.AddPropertyInfo(new() {
					{"name", _name},
					{"type", _setting["type"]},
					{"hint", _setting["hint"]},
					{"hint_string", _setting["hint_string"]}
				});
			}
		}
		ProjectSettings.Save();
	}

	public string _get_setting_path(Dictionary _setting){
		return "godotstg/" + _setting["name"];
	}

	public void _clear_settings(){
		foreach (Dictionary _setting in settings){
			ProjectSettings.Clear(_get_setting_path(_setting));
		}
		ProjectSettings.Save();
	}

}
#endif
