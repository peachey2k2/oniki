@tool
extends EditorPlugin

var bullets_directory:String
var settings:Array[Dictionary] = [
	{
		"name": "bullet_directory",
		"default": "res://addons/GodotSTG/bullets/default",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_DIR,
		"hint_string": ""
	},{
		"name": "collision_layer",
		"default": 2,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_LAYERS_2D_PHYSICS,
		"hint_string": ""
	}
] #TODO: fix this mess.

func _enter_tree():
	add_autoload_singleton("STGGlobal", "res://addons/GodotSTG/STGGlobal.gd")
	_setup_settings()

func _exit_tree():
	remove_autoload_singleton("STGGlobal")

func _disable_plugin():
	_clear_settings()

func _setup_settings():
	for _setting in settings:
		var _name = _get_setting_path(_setting)
		if !ProjectSettings.has_setting(_name):
			var _default = _setting.get("default")
			ProjectSettings.set(_name, _default)
			ProjectSettings.set_initial_value(_name, _default)
			ProjectSettings.add_property_info({
				"name": _name,
				"type": _setting.get("type"),
				"hint": _setting.get("hint"),
				"hint_string": _setting.get("hint_string")
			})
	ProjectSettings.save()

func _get_setting_path(_setting):
	return "godotstg/" + _setting.get("name")

func _clear_settings():
	for _setting in settings:
		ProjectSettings.clear(_get_setting_path(_setting))
	ProjectSettings.save()
