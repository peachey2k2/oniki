@tool
class_name STGBullet extends Area2D

var velocity:Vector2 = Vector2(0,0)
var acceleration:Vector2
var sine_freq:float
var sine_width:float
@onready var init_pos:Vector2
@onready var start_time:float
@onready var sine_direction:Vector2
var index:int

func _init():
	if Engine.is_editor_hint(): return
	collision_mask = 0
	monitoring = false
	input_pickable = false

func called():
	init_pos = position
	start_time = GFS.time(false)
	sine_direction = velocity.rotated(PI/2).normalized()

func _physics_process(delta):
	if Engine.is_editor_hint(): return
	velocity += acceleration * delta / 2
	init_pos += velocity*delta
	velocity += acceleration * delta / 2
	position = init_pos + sine_direction * sine_width * sin((GFS.time(false) - start_time) * sine_freq)

func remove():
	# animations
	STGGlobal.repool(self)
