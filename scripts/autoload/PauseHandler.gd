extends CanvasLayer

@onready var pressed_style_box = preload("res://themes/pressed.tres")

@onready var tree:SceneTree = get_tree()
@onready var ControlNode:Node = $Control
@onready var MenuContainer:Node = $"Control/MainContainer"
@onready var Pause:Node = $"Control/MainContainer/Pause"
@onready var Options:Node = $"Control/MainContainer/Options"
@onready var Saves:Node = $"Control/MainContainer/Saves"
@onready var ShaderBG:Node = $Control/ColorRect
@onready var TextureBG:Node = $Control/TextureRect

var curr_menu:Node
var menu_tree:Array[Array]
var sub_menu_open:bool = false
var choice_box
var curr_slot:int

var save_options:Array = ["Save", "Load", "Copy", "Delete"]
var resolution_options:Array = [
#"800x1280",
"1024x768",
"1280x720",
"1280x800",
"1280x1024",
"1360x768",
"1366x768",
"1440x900",
"1600x900",
"1680x1050",
"1920x1200",
"1920x1080",
"2560x1440",
#"2560x1080",
"2560x1600",
#"2880x1800",
#"3440x1440",
#"3840x2160",
#"5120x1440",
]

signal game_paused
signal game_unpaused
signal option_selected(index, menu_type)

func _ready():
	hide()
	
	#signals
	option_selected.connect(Callable(self, "_on_option_x_selected"))
	for Menu in MenuContainer.get_children():
		for i in Menu.get_children():
			if !i.name.begins_with("_"):
				if i is OptionButton:
					i.item_selected.connect(Callable(self, "_on_" + i.name + "_item_selected"))
				elif i is CheckButton:
					i.toggled.connect(Callable(self, "_on_" + i.name + "_toggled"))
				elif i is Button:
					i.pressed.connect(Callable(self, "_on_" + i.name + "_pressed"))
			else:
				if i.name.begins_with("_slot"):
					i.pressed.connect(Callable(self, "_on_slot_x_pressed").bind(i.get_index()))
				else:
					i.pressed.connect(Callable(self, "_on" + i.name + "_pressed"))

func _process(_delta):
#	if !DisplayServer.window_is_focused() && !GFS.in_dialogue && !tree.is_paused():
#		pause()
	if Input.is_action_just_pressed("pause") && !GFS.in_dialogue:
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
	if sub_menu_open:
		choice_box.queue_free()
		var prev_button = curr_menu.get_child(menu_tree[size-1][1])
		prev_button.grab_focus()
		prev_button.remove_theme_stylebox_override("normal")
		menu_tree.pop_back()
		sub_menu_open = false
		return
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
	if GFS.game_state == GFS.BATTLE:
		Pause.get_child(1).disabled = false
		Pause.get_child(2).disabled = false
	else:
		Pause.get_child(1).disabled = true
		Pause.get_child(2).disabled = true
	show()
	set_curr_menu(Pause)
	await RenderingServer.frame_post_draw
	var img = get_viewport().get_texture().get_image()
	TextureBG.set_texture(ImageTexture.create_from_image(img))
	MenuContainer.show()
	ShaderBG.hide()
	var BGFadeIn = create_tween()
	BGFadeIn.tween_property(TextureBG, "modulate", Color.WHITE, 0.2)

func unpause():
	MenuContainer.hide()
	curr_menu.hide()
	Pause.show()
	var BGFadeOut = create_tween()
	BGFadeOut.tween_property(TextureBG, "modulate", Color.TRANSPARENT, 0.2)
	if sub_menu_open:
		choice_box.queue_free()
		sub_menu_open = false
		curr_menu.get_child(menu_tree[menu_tree.size()-1][1]).remove_theme_stylebox_override("normal")
	menu_tree = []
	await get_tree().create_timer(0.2).timeout
	hide()
	ShaderBG.show()
	tree.set_pause(false)
	emit_signal("game_unpaused")

func create_choice_box(_index, _options, menu_type):
	sub_menu_open = true
	curr_slot = _index
	menu_tree.append([null, _index])
	choice_box = GFS.choice_box(_options, false)
	choice_box.set_meta("menu_type", menu_type)
	ControlNode.add_child(choice_box)
	choice_box.position = Vector2(150, 20) + Saves.get_child(_index).get_global_transform().origin
	var _container = choice_box.get_child(1)
	_container.get_child(0).grab_focus()

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

func _on_resolution_pressed():
	Options.get_child(0).add_theme_stylebox_override("normal", pressed_style_box)
	create_choice_box(0, resolution_options, "resolution")

func _on_fullscreen_toggled(state):
	match state:
		false: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		true: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	GFS.change_setting("fullscreen", state)

func _on_vsync_toggled(state):
	match state:
		false: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		true: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	GFS.change_setting("vsync", state)

# Saves

func _on_slot_x_pressed(_index:int):
	Saves.get_child(_index).add_theme_stylebox_override("normal", pressed_style_box)
	create_choice_box(_index, save_options, "save")

func _on_option_x_selected(_index, menu_type):
	match menu_type:
		"save": match _index:
			0:
				GFS.save_data(curr_slot + 1)
			1:
				GFS.load_data(curr_slot + 1)
				unpause()
			2: pass
			3: pass
		"resolution":
			var res_str:String = resolution_options[_index]
			ProjectSettings.set("display/window/size/viewport_width", res_str.get_slice("x", 0))
			ProjectSettings.set("display/window/size/viewport_height", res_str.get_slice("x", 1))
