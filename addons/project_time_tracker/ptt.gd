@tool
extends EditorPlugin

var dock

func _enter_tree():
	# Load the dock scene and instantiate it.
	dock = preload("res://addons/project_time_tracker/ptt_dock.tscn").instantiate()

	# Add the loaded scene to the docks.
	add_control_to_dock(DOCK_SLOT_LEFT_BR, dock)


func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()

