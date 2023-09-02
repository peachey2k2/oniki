extends Node2D

@onready var root:Node = $"/root"

func _ready():
	$Button.connect("pressed",Callable(self,"_on_button_pressed"))

func _on_button_pressed():
	GFS.start()
	queue_free()
