extends Node

const AUTOSAVE_INTERVAL = 30

const BUI_X_START = 0
const BUI_X_END = 880
const BUI_Y_START = 0
const BUI_Y_END = 880

const BATTLE_RECT = Rect2(BUI_X_START, BUI_Y_START, 880, 880)

const CHOICE_BOX_POS = Vector2(0, 200)

signal proceed_dialogue
signal dialogue_start
signal dialogue_end
signal option_selected(index:int, is_for_dialogue:bool)

@onready var BattleArena = preload("res://scenes/Battle.tscn")
@onready var SpeechBoxDefault = preload("res://scenes/SpeechBox.tscn")
@onready var ChoiceBoxDefault = preload("res://scenes/ChoiceBox.tscn")
@onready var PlainTextBoxDefault = preload("res://scenes/PlainTextBox.tscn")
@onready var BallDefault = preload("res://scenes/Ball.tscn")
@onready var ChoiceButton = preload("res://scenes/ChoiceButton.tscn")
@onready var OutlineMaterial = preload("res://themes/OutlineMaterial.tres")
@onready var root:Node = get_tree().root
@onready var Rng:RandomNumberGenerator = RandomNumberGenerator.new()

enum {NONE, MENU, WORLD, BATTLE}
var game_state:int = 0

var game_settings:Dictionary

var Player:Node
var Enemy:Node
var player_pos:Vector2
var Overworld:Node
var LastSprite:Node
var CurrentArena:Node
var ArenaViewport:Node
var Controller:Node
var PlayerCamera:Node
var Ball:Node
var SharedArea:Node
var Temporary:Node

var _dialogue:ClydeDialogue
var in_dialogue:bool = false
var last_speech_box:Node
var last_choice_box:Node

func _physics_process(_delta):
	if Input.is_action_just_pressed("quicksave") && game_state == WORLD:
		save_data()
		var text_box = PlainTextBoxDefault.instantiate()
		text_box.text = "Game Saved!"
		PlayerCamera.add_child(text_box)
		
	if (Input.is_action_just_pressed("interact") || Input.is_action_pressed("skip_dialogue")) && last_choice_box == null:
		emit_signal("proceed_dialogue")
		
	if Input.is_action_just_pressed("screenshot"):
		var img = get_viewport().get_texture().get_image()
		DirAccess.make_dir_absolute("user://screenshots")
		img.save_png("user://screenshots/" + str(Time.get_unix_time_from_system()) + ".png")

func _ready():
#	get_tree().get_root().set_disable_input(true)
	
	# self explanatory
	load_settings()
	
	# start the autosave cycle
	autosave()
	
	# le epic rng randomization
	Rng.randomize()
	
	# dialogue stuff
	_dialogue = ClydeDialogue.new()
	_dialogue.connect("event_triggered", Callable(self, "_on_dialogue_event_triggered"))
	_dialogue.load_dialogue("test")
	
	# signals
	get_viewport().connect("size_changed", Callable(self, "_on_screen_size_changed"))
	STGGlobal.end_battle.connect(Callable(self, "unload_battle"))
	option_selected.connect(Callable(self, "_on_option_selected"))
	dialogue_end.connect(Callable(self, "_on_dialogue_end"))
	
	# function to initialize the actual game
	start()

func load_settings():
	DirAccess.make_dir_absolute("user://saves")
	var file = FileAccess.open("user://saves/settings.json", FileAccess.READ)
	if file == null: return
	var json = JSON.new()
	json.parse(file.get_as_text())
	game_settings = json.get_data()
	file.close()
	for i in game_settings.keys():
		var _option = PauseHandler.Options.get_node(i)
		if _option is CheckButton:
			_option.set_pressed(game_settings[i])

func change_setting(setting, value):
	game_settings[setting] = value
	var file = FileAccess.open("user://saves/settings.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(game_settings, "\t"))
	file.close()

func load_data(slot:int = 0):
	var savefile = FileAccess.open("user://saves/slot_" + str(slot) + ".save", FileAccess.READ)
	if savefile == null: return
	Player.position = savefile.get_var()
	savefile.close()

func save_data(slot:int = 0):
	var _data = get_data()
	var savefile = FileAccess.open("user://saves/slot_" + str(slot) + ".save", FileAccess.WRITE_READ)
	for i in _data:
		savefile.store_var(i)
	savefile.close()

func autosave():
	while true:
		await get_tree().create_timer(AUTOSAVE_INTERVAL, false).timeout
		if game_state == MENU || game_state == WORLD:
			save_data()

func get_data() -> Array:
	var _data:Array = []
	_data.append(Player.position)
	return _data

func play_dialogue(id:String):
	if !in_dialogue:
		in_dialogue = true
		dialogue_start.emit()
		_dialogue.start(id)
		while in_dialogue:
			var next_content = _dialogue.get_content()
			if next_content == null || next_content.get("tags").has("END"):
#				await proceed_dialogue
				in_dialogue = false
				dialogue_end.emit()
				return
#			print(next_content) #print the next line of dialogue
			_print_dialogue(next_content)
			if next_content.get("tags").has("NEXT"):
				continue
			await get_tree().create_timer(0.1, false).timeout
			await proceed_dialogue
		dialogue_end.emit()
		return

func _print_dialogue(content:Dictionary):
	var nodes_list:Array
	match game_state:
		WORLD: nodes_list = Overworld.get_children()
	assert(content.get("speaker") != "Player", "nooooooo you can't make the silent protag-kun speak without a choice dialogue, that ruins the lore!!!!! :soyjak:")
	match content.get("type"):
		"options":
			var _options:Array = []
			for _option in content.get("options"):
				_options.append(_option.get("label"))
			var _choice_box = choice_box(_options)
			PlayerCamera.add_child(_choice_box)
			_choice_box.position = CHOICE_BOX_POS - (_choice_box.size / 2)
			_choice_box.get_child(1).get_child(0).grab_focus()
			last_choice_box = _choice_box
		"line":
			for _node in nodes_list:
				if _node.name == content.get("speaker"):
					var SpeechBox = SpeechBoxDefault.instantiate()
					if last_speech_box != null: last_speech_box.free()
					if last_choice_box != null: last_choice_box.free()
					SpeechBox.get_child(0).text = content.get("text")
					_node.add_child(SpeechBox)
					SpeechBox.position = Vector2(0, -60) - (SpeechBox.size / 2)
					last_speech_box = SpeechBox
					return
		_:
			assert(false, "fun fact: this assert is untriggerable.")

func _on_dialogue_event_triggered(event_name:String):
	if event_name.match("battle_*"):
		dialogue_end.emit()
		load_battle(event_name.trim_prefix("battle_"))

func choice_box(_options:Array, is_for_dialogue:bool = true) -> MarginContainer:
	var ChoiceBox_ins = ChoiceBoxDefault.instantiate()
	var _container = ChoiceBox_ins.get_node("Container")
	_container.set_meta("is_for_dialogue", is_for_dialogue)
	for _option in _options:
		var _button = ChoiceButton.instantiate()
		_button.text = _option
		_container.add_child(_button)
	return ChoiceBox_ins

func _on_option_selected(index:int):
	_dialogue.choose(index)
	proceed_dialogue.emit()

func _on_dialogue_end():
	if last_speech_box != null: last_speech_box.free()
	if last_choice_box != null: last_choice_box.free()

func start():
	game_state = NONE
#	await STGGlobal.pool_all()
	Overworld = load("res://scenes/overworld.tscn").instantiate()
	Player = load("res://scenes/Player.tscn").instantiate()
	PlayerCamera = Player.get_node("PlayerCamera")
	root.add_child.call_deferred(Overworld)
	Overworld.add_child.call_deferred(Player)
	root.get_node("MenuRoot").queue_free()
	load_data()
	game_state = WORLD

func load_battle(id:String):
	game_state = NONE
	Controller = load("res://scenes/battles/" + id + ".tscn").instantiate()
	player_pos = Player.position
	var Sprite:Node = load("res://scenes/SpriteTemplate.tscn").instantiate()
	Sprite.texture = load("res://assets/sprites/" + id + ".png")
	in_dialogue = false
	Enemy = load("res://scenes/Enemy.tscn").instantiate()
	Enemy.id = id
	CurrentArena = BattleArena.instantiate()
	ArenaViewport = CurrentArena.get_node("./SubViewportContainer/Arena")
	Enemy.add_child(Sprite.duplicate())
	Enemy.z_index = -1
	root.remove_child(Overworld)
	root.add_child(CurrentArena)
#	Ball = BallDefault.instantiate()
	# i have no fucking clue why, but the engine shits itself
	# if this move_child() isn't called deferred.
	root.move_child.call_deferred(PauseHandler, -1)
	Player.get_node("./ExtraColliders/Hitbox/CollisionShape2D").disabled = false
	Player.reparent(ArenaViewport)
	ArenaViewport.add_child(Enemy)
	Player.shoot.connect(Callable(Enemy, "_on_player_shoot"))
	STGGlobal.spell_changed.connect(Callable(Enemy, "_on_spell_changed"))
	STGGlobal.end_spell.connect(Callable(Enemy, "_on_end_spell"))
	LastSprite = Sprite
	ArenaViewport.add_child(Controller)
#	ArenaViewport.add_child(Ball)
	Temporary = ArenaViewport.get_node("Temp")
	Controller.player = Player
	Controller.enemy = Enemy
	Controller.arena_rect = BATTLE_RECT
	STGGlobal.arena_rect = BATTLE_RECT
	Player.position = STGGlobal.lerp4arena(Vector2(0.5, 0.8))
	Controller.start()
	game_state = BATTLE

func reload_battle():
	game_state = NONE
#	Controller.stats = null
	ArenaViewport.remove_child(Player)
	ArenaViewport.add_child(Player) # yes trust me this is necessary
	ArenaViewport.move_child(Player, -2)
	Player.resurrect()
#	Ball.free()
#	Ball = BallDefault.instantiate()
#	ArenaViewport.add_child(Ball)
	for i in Temporary.get_children():
		i.queue_free()
#	Controller.kill()
	await get_tree().process_frame
#	Controller = load("res://scenes/battles/" + Enemy.id + ".tscn").instantiate()
#	Controller.player = Player
#	Controller.enemy = Enemy
#	Controller.arena_rect = BATTLE_RECT
#	ArenaViewport.add_child(Controller)
	Controller.start()
#	Controller.enemy = Enemy
	game_state = BATTLE

func unload_battle():
	game_state = NONE
	Player.resurrect()
	for i in Temporary.get_children():
		i.queue_free()
	root.remove_child(CurrentArena)
	root.add_child(Overworld)
	Player.get_node("./ExtraColliders/Hitbox/CollisionShape2D").disabled = true
	Player.reparent(Overworld)
	Player.position = player_pos
	CurrentArena.queue_free()
	Controller.kill()
	game_state = WORLD

func get_distance(node1:Node, node2:Node) -> float:
	return node1.global_transform.origin.distance_to(node2.global_transform.origin)

# useless for now
#func get_distance_as_vector(node1:Node, node2:Node) -> Vector2:
#	return node2.global_transform.origin - node1.global_transform.origin

func get_angle(node1:Node2D, node2:Node2D) -> float:
	return node1.global_transform.origin.angle_to_point(node2.global_transform.origin)

func get_angle_as_vector(node1:Node, node2:Node) -> Vector2:
	return (node2.global_transform.origin - node1.global_transform.origin).normalized()

func bui_lerp(weight:Vector2) -> Vector2:
	return weight * 880
