extends Button

func _ready():
	pressed.connect(Callable(self, "_on_pressed"), 1)

func _on_pressed():
	GFS.option_selected.emit(get_index())
