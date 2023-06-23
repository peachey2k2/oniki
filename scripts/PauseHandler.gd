extends Control

@onready var tree:SceneTree = get_tree()
signal game_paused
signal game_unpaused

func _ready():
	$"MainContainer/VBoxContainer/Button".connect("pressed",Callable(self,"_on_button_pressed"))

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		tree.set_pause(!tree.is_paused())
		print(tree.is_paused())
		if tree.is_paused():
			emit_signal("game_paused")
			$MainContainer.show()
		else:
			emit_signal("game_unpaused")
			$MainContainer.hide()
			
func _on_button_pressed():
	print(":)")
