extends Node

const TIMER_START = 1000000

const BUI_X_START = 0
const BUI_X_END = 880
const BUI_Y_START = 0
const BUI_Y_END = 880

const BATTLE_RECT = Rect2(BUI_X_START, BUI_Y_START, 880, 880)

const CHOICE_BOX_POS = Vector2(0, 200)

signal proceed_dialogue

@onready var BattleArena = preload("res://scenes/Battle.tscn")
@onready var SpeechBoxDefault = preload("res://scenes/SpeechBox.tscn")
@onready var ChoiceBox = preload("res://scenes/ChoiceBox.tscn")
@onready var ChoiceButton = preload("res://scenes/ChoiceButton.tscn")
@onready var root:Node = get_tree().root
@onready var Rng:RandomNumberGenerator = RandomNumberGenerator.new()

enum {NONE, MENU, WORLD, BATTLE}
var game_state:int = 0

var Player:Node
var Enemy:Node
var player_pos:Vector2
var Overworld:Node
var PauseHandler:Node
var LastSprite:Node
var CurrentArena:Node
var ArenaViewport:Node
var Controller:Node

var _dialogue:ClydeDialogue
var in_dialogue:bool = false
var speech_boxes:Array = []

var clock:float
var clock_real:float
var clock_timer:SceneTreeTimer
var clock_real_timer:SceneTreeTimer

func _physics_process(_delta):
	if Input.is_action_just_pressed("debug"):
		pass
	if Input.is_action_just_pressed("interact") || Input.is_action_pressed("skip_dialogue"):
		emit_signal("proceed_dialogue")
	if Input.is_action_just_pressed("screenshot"):
		var img = get_viewport().get_texture().get_image()
		DirAccess.make_dir_absolute("user://screenshots")
		img.save_png("user://screenshots/" + str(Time.get_unix_time_from_system()) + ".png")

func _ready():
	Rng.randomize()
	_dialogue = ClydeDialogue.new()
	_dialogue.connect("event_triggered", Callable(self, "_on_dialogue_event_triggered"))
	_dialogue.load_dialogue("test")
	
	get_viewport().connect("size_changed", Callable(self, "_on_screen_size_changed"))
	STGGlobal.end_battle.connect(Callable(self, "unload_battle"))
	
	clock_timer = get_tree().create_timer(TIMER_START, false)
	clock_real_timer = get_tree().create_timer(TIMER_START, true)
	
	start()

func _clear_speech_boxes():
	for i in speech_boxes:
		i.queue_free()
	speech_boxes.clear()

func play_dialogue(id:String):
	if !in_dialogue:
		in_dialogue = true
		_dialogue.start(id)
		while true:
			if !in_dialogue:
				return
			var next_content = _dialogue.get_content()
			if next_content == null || next_content.get("tags").has("END"):
				await proceed_dialogue
				in_dialogue = false
				_clear_speech_boxes()
				return
			print(next_content) #print the next line of dialogue
			_print_dialogue(next_content)
			await proceed_dialogue

func _print_dialogue(content:Dictionary):
	var nodes_list:Array
	match game_state:
		WORLD: nodes_list = Overworld.get_children()
	assert(content.get("speaker") != "Player", "nooooooo you can't make the silent protag-kun speak without a choice dialogue, that ruins the lore!!!!! :soyjak:")
	if content.get("type") == "options":
		var _options:Array = []
		for _option in content.get("options"):
			_options.append(_option.get("label"))
		var _choice_box = choice_box(_options)
		Player.get_node("PlayerCamera").add_child(_choice_box)
		_choice_box.position = CHOICE_BOX_POS - (_choice_box.size / 2)
		_choice_box.get_child(1).get_child(0).grab_focus()
		return
	for i in nodes_list:
		if i.name == content.get("speaker"):
			var SpeechBox:Node = i.get_node_or_null("SpeechBox")
			if SpeechBox == null:
				SpeechBox = SpeechBoxDefault.instantiate()
				SpeechBox.position = Vector2(0, -100)
				i.add_child(SpeechBox)
				speech_boxes.append(SpeechBox)
			SpeechBox.get_child(0).text = content.get("text")
			return

func _on_dialogue_event_triggered(event_name:String):
	if event_name.match("battle_*"):
		proceed_dialogue.emit()
		load_battle(event_name.trim_prefix("battle_"))

func choice_box(_options:Array) -> MarginContainer:
	var ChoiceBox_ins = ChoiceBox.instantiate()
	var _container = ChoiceBox_ins.get_node("Container")
	for _option in _options:
		var _button = ChoiceButton.instantiate()
		_button.text = _option
		_container.add_child(_button)
	return ChoiceBox_ins

func time(count_while_paused:bool) -> float:
	if count_while_paused:
		return TIMER_START - clock_real_timer.get_time_left()
	else:
		return TIMER_START - clock_timer.get_time_left()

func start():
	game_state = NONE
	await STGGlobal.pool_all()
	Overworld = load("res://scenes/overworld.tscn").instantiate()
	PauseHandler = load("res://scenes/PauseHandler.tscn").instantiate()
	Player = load("res://scenes/Player.tscn").instantiate()
	root.add_child.call_deferred(Overworld)
	root.add_child.call_deferred(PauseHandler)
	root.add_child.call_deferred(Player)
	root.get_node("MenuRoot").queue_free()
	game_state = WORLD

func load_battle(id:String):
	game_state = NONE
	Controller = load("res://scenes/battles/" + id + ".tscn").instantiate()
	_clear_speech_boxes()
	player_pos = Player.position
	var Sprite:Node = load("res://scenes/SpriteTemplate.tscn").instantiate()
	Sprite.texture = load("res://assets/sprites/" + id + ".png")
	in_dialogue = false
	Enemy = load("res://scenes/Enemy.tscn").instantiate()
	Enemy.id = id
	CurrentArena = BattleArena.instantiate()
	ArenaViewport = CurrentArena.get_node("./SubViewportContainer/Arena")
	Enemy.add_child(Sprite.duplicate())
	root.remove_child(Overworld)
	root.add_child(CurrentArena)
	root.move_child(PauseHandler, -1)
	Player.get_node("./ExtraColliders/Hitbox/CollisionShape2D").disabled = false
	Player.reparent(ArenaViewport)
	ArenaViewport.add_child(Enemy)
	Player.connect("shoot", Callable(CurrentArena.get_node("BattleUI/LifeBarContainer"),"_on_player_shoot"))
	Player.get_node("ExtraColliders/GrazeDetection").connect("area_entered", Callable(CurrentArena.get_node("BattleUI/Graze"),"_on_area_entered"))
	LastSprite = Sprite
	ArenaViewport.add_child(Controller)
	Controller.start(ArenaViewport.get_node("Spawners"), Player, Enemy, BATTLE_RECT)
	game_state = BATTLE

func reload_battle():
	game_state = NONE
	Controller.stats = null
	Player.resurrect()
	for i in ArenaViewport.get_node("Spawners").get_children():
		i.remove()
	Controller.free()
	Controller = load("res://scenes/battles/" + Enemy.id + ".tscn").instantiate()
	ArenaViewport.add_child(Controller)
	Controller.start(ArenaViewport.get_node("Spawners"), Player, Enemy, BATTLE_RECT)
	game_state = BATTLE

func unload_battle():
	game_state = NONE
	Player.is_alive = true
	Player.process_mode = Node.PROCESS_MODE_INHERIT
	Player.show()
	root.remove_child(CurrentArena)
	root.add_child(Overworld)
	Player.get_node("./ExtraColliders/Hitbox/CollisionShape2D").disabled = true
	Player.reparent(Overworld)
	Player.position = player_pos
	CurrentArena.queue_free()
	game_state = WORLD

func get_distance(node1:Node, node2:Node) -> float:
	return node1.global_transform.origin.distance_to(node2.global_transform.origin)

func get_angle(node1:Node, node2:Node) -> float:
	return node1.global_transform.origin.angle_to_point(node2.global_transform.origin)

func get_angle_as_vector(node1:Node, node2:Node) -> Vector2:
	return (node2.global_transform.origin - node1.global_transform.origin).normalized()

func bui_lerp(weight:Vector2) -> Vector2:
	return weight * 880
