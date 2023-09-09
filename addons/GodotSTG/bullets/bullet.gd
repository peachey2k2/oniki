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

var sprite_outer:Node
var sprite_inner:Node
var collision:Node

func _init():
	collision_mask = 0
	monitoring = false
	input_pickable = false
	sprite_outer = Sprite2D.new()
	sprite_inner = Sprite2D.new()
	collision = CollisionShape2D.new()
	add_child(sprite_outer)
	add_child(sprite_inner)
	add_child(collision)

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
