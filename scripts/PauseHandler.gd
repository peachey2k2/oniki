extends Control

@onready var tree:SceneTree = get_tree()
@onready var menu:Node = $"MainContainer/PauseMenu"
signal game_paused
signal game_unpaused

func _ready():
	hide()
	for i in menu.get_child_count():
		menu.get_child(i).connect("pressed", Callable(self, "_on_button_" + str(i) + "_pressed"))

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		tree.set_pause(!tree.is_paused())
		if tree.is_paused():
			emit_signal("game_paused")
			show()
			menu.get_child(0).grab_focus()
		else:
			emit_signal("game_unpaused")
			hide()
			
func _on_button_0_pressed():
	tree.set_pause(false)
	emit_signal("game_unpaused")
	hide()
	
func _on_button_1_pressed():
	pass

func _on_button_2_pressed():
	pass
	
func _on_button_3_pressed():
	tree.quit()
