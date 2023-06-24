extends Node2D

@onready var root:Node = $"/root"

func _ready():
	$Button.connect("pressed",Callable(self,"_on_button_pressed"))

func _on_button_pressed():
	var Battle:Node = load("res://scenes/Battle.tscn").instantiate()
	var PauseHandler:Node = load("res://scenes/PauseHandler.tscn").instantiate()
	root.add_child(Battle)
	root.add_child(PauseHandler)
	queue_free()
