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
		if tree.is_paused():
			unpause()
		else:
			pause()

func pause():
	tree.set_pause(true)
	emit_signal("game_paused")
	position -= get_screen_position()
	show()
	menu.get_child(0).grab_focus()
	
func unpause():
	tree.set_pause(false)
	emit_signal("game_unpaused")
	hide()

func _on_button_0_pressed():
	unpause()

func _on_button_1_pressed():
	if GFS.game_state == 3:
		GFS.restart_battle()
		unpause()

func _on_button_2_pressed():
	if GFS.game_state == 3:
		GFS.end_battle()
		unpause()

func _on_button_3_pressed():
	pass

func _on_button_4_pressed():
	pass

func _on_button_5_pressed():
	tree.quit()
