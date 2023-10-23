extends CharacterBody2D

const SPEED = 300
const HIT_COOLDOWN = 0.8
const MARGIN = 10
const FADE_PER_SECOND = 8

var direction:Vector2
var hitOnCooldown:bool = false
var facing:float = 0
var directional_string  = "right"
var is_alive:bool = true

var closest_dist:float = INF
var closest_node:Node = null

@onready var GrazeBox:Node = $ExtraColliders/GrazeDetection
@onready var InteractBox:Node = $ExtraColliders/InteractDetection
@onready var Hitbox:Node = $ExtraColliders/Hitbox
@onready var Slash:Node = $Slash
@onready var Sprite:Node = $PlayerSprite

signal shoot

func _ready():
#	material.set_shader_parameter("line_color", Color.WHITE)
	GFS.dialogue_start.connect(Callable(self, "_on_dialogue_start"))
	GFS.dialogue_end.connect(Callable(self, "_on_dialogue_end"))

func _on_dialogue_start():
	pass
#	process_mode = Node.PROCESS_MODE_DISABLED

func _on_dialogue_end():
	pass
#	process_mode = Node.PROCESS_MODE_INHERIT

func _physics_process(delta):
	if !Hitbox.monitoring:
		Hitbox.monitoring = true
	if !GFS.in_dialogue:
		direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
		direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
		
		if Input.is_action_pressed("skip_dialogue"):
			direction*=3
			Sprite.speed_scale = 2
		if Input.is_action_pressed("focus") && !Input.is_action_pressed("skip_dialogue"):
			direction*=0.45
			$ExtraColliders.modulate.a = clamp($ExtraColliders.modulate.a + FADE_PER_SECOND * delta, 0, 1)
			Sprite.speed_scale = 0.5
		else:
			$ExtraColliders.modulate.a = clamp($ExtraColliders.modulate.a - FADE_PER_SECOND * delta, 0, 1)
			Sprite.speed_scale = 1
		velocity = direction*SPEED
		move_and_slide()
		
	if velocity != Vector2.ZERO && !GFS.in_dialogue:
		facing = velocity.angle()
		directional_string  = _get_direction_string(facing)
		Sprite.play("walk_" + directional_string)
	else:
		Sprite.play("stop_" + directional_string)
	
	$"ExtraColliders/HitDetection/Sprite2D".rotate(0.3 * delta)
	$"ExtraColliders/GrazeDetection/Sprite2D".rotate(-0.4 * delta)
	
	closest_dist = INF
	closest_node = null
	if !InteractBox.get_overlapping_areas().is_empty():
		for i in InteractBox.get_overlapping_areas():
			var dist:float = GFS.get_distance(self, i)
			i.material = null
			if dist < closest_dist:
				closest_dist = dist
				closest_node = i
		closest_node.material = GFS.OutlineMaterial

func hit():
	Hitbox.monitoring = false
	hitOnCooldown = true
	slash_animation()
	emit_signal("shoot")
	await get_tree().create_timer(HIT_COOLDOWN, false).timeout
	hitOnCooldown = false

func _get_direction_string(angle:float) -> String:
	var angle_deg = round(rad_to_deg(angle))
	if abs(angle_deg) == 90:
		return directional_string
	if abs(angle_deg) < 90:
		return "right"
	return "left"

func slash_animation():
	if GFS.game_state == GFS.BATTLE:
		Slash.rotation = GFS.get_angle(self, GFS.Enemy)
	else:
		Slash.rotation = facing
	Slash.modulate = Color.WHITE
	var tw = create_tween()
	tw.tween_property(Slash, "modulate", Color.TRANSPARENT, 0.1)
	Slash.flip_v = !Slash.flip_v

func _process(_delta):
	if GFS.game_state == GFS.BATTLE:
		position = Vector2(
			clamp(position.x, GFS.BUI_X_START + MARGIN, GFS.BUI_X_END - MARGIN),
			clamp(position.y, GFS.BUI_Y_START + MARGIN, GFS.BUI_Y_END - MARGIN)
		)
	
	if Input.is_action_pressed("interact"):
		if closest_node == null:
			if !hitOnCooldown && is_alive:
				hit()
		elif Input.is_action_just_pressed("interact"):
			closest_node.on_interact()

func _on_Hitbox_area_entered(_area):
	is_alive = false
	hide()
	set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)

func resurrect():
	is_alive = true
	process_mode = Node.PROCESS_MODE_INHERIT
	show()

func _on_interact_detection_area_exited(area):
	area.material = null
	if area == closest_node:
		closest_node = null
