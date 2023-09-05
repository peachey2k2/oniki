extends Control

@onready var Menu = $MarginContainer/Menu

func _ready():
	for i in Menu.get_children():
		i.connect("pressed", Callable(self, "_on_" + i.name + "_pressed"))
	Menu.get_child(0).grab_focus()

func _on_play_pressed():
	GFS.start()
	queue_free()
