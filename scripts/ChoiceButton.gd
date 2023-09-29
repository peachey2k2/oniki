extends Button

func _ready():
	pressed.connect(Callable(self, "_on_pressed"), 1)

func _on_pressed():
	if get_parent().get_meta("is_for_dialogue"):
		GFS.option_selected.emit(get_index())
	else:
		PauseHandler.option_selected.emit(get_index(), get_parent().get_parent().get_meta("menu_type"))
