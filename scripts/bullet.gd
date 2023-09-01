extends Area2D

var velocity:Vector2 = Vector2(0,0)
var acceleration:Vector2
var sine_freq:float
var sine_width:float
@onready var init_pos:Vector2 = position
@onready var start_time:float = GFS.time(false)
@onready var sine_direction:Vector2 = velocity.rotated(PI/2).normalized()

func _physics_process(delta):
	velocity += acceleration * delta / 2
	init_pos += velocity*delta
	velocity += acceleration * delta / 2
	position = init_pos + sine_direction * sine_width * sin((GFS.time(false) - start_time) * sine_freq)

