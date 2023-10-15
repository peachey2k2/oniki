@tool
class_name STGBullet extends Area2D

var velocity:Vector2 = Vector2(0,0)
var acceleration:Vector2
var sine_freq:float
var sine_width:float
var data:STGBulletModifier
@onready var init_pos:Vector2
@onready var start_time:float
@onready var sine_direction:Vector2
var index:int:
	set = set_index
var adjusted_process:Callable

func _init():
	if Engine.is_editor_hint(): return
	collision_mask = 0
	monitoring = false
	input_pickable = false

func called_low(pos, vel, color_outer, color_inner):
	adjusted_process = Callable(self, "_adjusted_process_low")
	position = pos
	velocity = vel
	$sprite.texture.gradient.colors = [color_inner, color_inner, color_outer, color_outer, Color.TRANSPARENT]
	set_deferred("process_mode", PROCESS_MODE_INHERIT)

func called(pos, vel, acc, color_outer, color_inner):
	adjusted_process = Callable(self, "_adjusted_process")
	position = pos
	velocity = vel
	acceleration = acc
	$sprite.texture.gradient.colors = [color_inner, color_inner, color_outer, color_outer, Color.TRANSPARENT]
	init_pos = position
	start_time = GFS.time(false)
	sine_direction = velocity.rotated(PI/2).normalized()
	set_deferred("process_mode", PROCESS_MODE_INHERIT)

## function to modify the bullet. you can use flags to omit some of the variables
func modify(mod:STGBulletModifier, flags:int = 1):
#	if !(flags & 1) != 0: position = pos
	if !(flags & 2): velocity = velocity.normalized() * mod.speed
	if !(flags & 4): acceleration = velocity.normalized() * mod.acceleration
	if !(flags & 8): $sprite.texture.gradient.colors = [mod.inner_color, mod.inner_color, mod.outer_color, mod.outer_color, Color.TRANSPARENT]

var last_pos:Vector2

func _physics_process(delta):
	if Engine.is_editor_hint(): return
	adjusted_process.call(delta)

func _adjusted_process_low(delta):
	position += velocity*delta

func _adjusted_process(delta):
	velocity += acceleration * delta * 0.5
	init_pos += velocity*delta
	velocity += acceleration * delta * 0.5
	position = init_pos + sine_direction * sine_width * sin((GFS.time(false) - start_time) * sine_freq)

func remove():
	# animations
	STGGlobal.repool(self)

func set_index(val):
	index = val
	return self
