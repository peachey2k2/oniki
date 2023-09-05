extends Control

@onready var tree:SceneTree = get_tree()
@onready var Menu:Node = $"MainContainer/PauseMenu"
signal game_paused
signal game_unpaused

func _ready():
	hide()
	for i in Menu.get_children():
		i.connect("pressed", Callable(self, "_on_" + i.name + "_pressed"))

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
	Menu.get_child(0).grab_focus()

func unpause():
	tree.set_pause(false)
	emit_signal("game_unpaused")
	hide()

func _on_return_to_game_pressed():
	unpause()

func _on_restart_current_battle_pressed():
	if GFS.game_state == 3:
		GFS.restart_battle()
		unpause()

func _on_leave_battle_pressed():
	if GFS.game_state == 3:
		GFS.end_battle()
		unpause()

func _on_options_pressed():
	pass

func _on_main_menu_pressed():
	pass

func _on_quit_pressed():
	tree.quit()
