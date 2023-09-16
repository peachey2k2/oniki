extends CanvasLayer

@onready var tree:SceneTree = get_tree()
@onready var ControlNode:Node = $Control
@onready var MenuContainer:Node = $"Control/MainContainer"
@onready var Pause:Node = $"Control/MainContainer/Pause"
@onready var Options:Node = $"Control/MainContainer/Options"
@onready var Saves:Node = $"Control/MainContainer/Saves"
var curr_menu:Node
var menu_tree:Array[Array]
signal game_paused
signal game_unpaused

func _ready():
	hide()
	for Menu in MenuContainer.get_children():
		for i in Menu.get_children():
			if i is OptionButton:
				i.connect("item_selected", Callable(self, "_on_" + i.name + "_item_selected"))
			elif i is CheckButton:
				i.connect("toggled", Callable(self, "_on_" + i.name + "_toggled"))
			elif i is Button:
				i.connect("pressed", Callable(self, "_on_" + i.name + "_pressed"))

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		if tree.is_paused():
			back()
		else:
			pause()

func set_curr_menu(menu:Node, index:int = -1):
	menu.get_child(0).grab_focus()
	curr_menu = menu
	menu_tree.append([menu, index])

func switch_menu(menu:Node, index:int = -1):
	curr_menu.hide()
	if index < 0:
		curr_menu = menu
	else:
		set_curr_menu(menu, index)
	menu.show()

func back():
	var size = menu_tree.size()
	if size > 1:
		switch_menu(menu_tree[size-2][0], -1)
		curr_menu.get_child(menu_tree[size-1][1]).grab_focus()
	else:
		unpause()
	menu_tree.pop_back()

func pause():
	tree.set_pause(true)
	emit_signal("game_paused")
	ControlNode.position -= ControlNode.get_screen_position()
	show()
	set_curr_menu(Pause)

func unpause():
	tree.set_pause(false)
	emit_signal("game_unpaused")
	hide()

# Menu

func _on_return_to_game_pressed():
	unpause()

func _on_restart_current_battle_pressed():
	if GFS.game_state == 3:
		GFS.reload_battle()
		unpause()

func _on_leave_battle_pressed():
	if GFS.game_state == 3:
		GFS.unload_battle()
		unpause()

func _on_options_pressed():
	switch_menu(Options, 3)

func _on_saves_pressed():
	switch_menu(Saves, 4)

func _on_quit_pressed():
	tree.quit()

# Options

func _on_fullscreen_toggled(state):
	match state:
		false: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		true: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_vsync_toggled(state):
	match state:
		false: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		true: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
