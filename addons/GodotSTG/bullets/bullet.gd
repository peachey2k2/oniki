@tool
class_name STGBullet extends Area2D

enum {MODIFY_OMIT_POSITION, MODIFY_OMIT_VELOCITY, MODIFY_OMIT_ACCELERATION, MODIFY_OMIT_TEXTURE, MODIFY_OMIT_LIFESPAN}

@export var Sprite:Sprite2D
@export var Collision:CollisionShape2D

var init_pos:Vector2
var start_time:float
var sine_direction:Vector2
var velocity:Vector2 = Vector2(0,0)
var acceleration:Vector2
var sine_freq:float
var sine_width:float
var data:STGBulletModifier
var index:int
var adjusted_process:Callable
var last_pos:Vector2
var lifespan:SceneTreeTimer

func _init():
	if Engine.is_editor_hint(): return
	collision_layer = STGGlobal.COLLISION_LAYER

func _ready():
	Sprite.texture = Sprite.texture.duplicate()
	Sprite.texture.gradient = Sprite.texture.gradient.duplicate() #this kills the fps. fix it later.

func called_low(pos, vel, id):
	adjusted_process = Callable(self, "_adjusted_process_low")
	position = pos
	velocity = vel
	Sprite.texture = STGGlobal.textures[id]
	set_deferred("process_mode", PROCESS_MODE_INHERIT)
	await tree_entered
	if data.lifespan > 0:
		lifespan = get_tree().create_timer(data.lifespan, false)
		lifespan.timeout.connect(Callable(self, "remove"))

func called(pos, vel, acc, id):
	adjusted_process = Callable(self, "_adjusted_process")
	position = pos
	velocity = vel
	acceleration = acc
	Sprite.texture = STGGlobal.textures[id]
	init_pos = position
	start_time = STGGlobal.time(false)
	sine_direction = velocity.rotated(PI/2).normalized()
	set_deferred("process_mode", PROCESS_MODE_INHERIT)
	await tree_entered
	if data.lifespan > 0:
		lifespan = get_tree().create_timer(data.lifespan, false)
		lifespan.timeout.connect(Callable(self, "remove"))

## function to modify the bullet. you can use flags to omit some of the variables
func modify(mod:STGBulletModifier, flags:int = MODIFY_OMIT_POSITION):
#	if !(flags & 1):  position = pos
	if !(flags & 2):  velocity = velocity.normalized() * mod.speed
	if !(flags & 4):  acceleration = velocity.normalized() * mod.acceleration
	if !(flags & 8):  Sprite.texture = STGGlobal.textures[mod.id]
	if !(flags & 16) && mod.lifespan > 0:
		lifespan = get_tree().create_timer(mod.lifespan, false)
		lifespan.timeout.connect(Callable(self, "remove"))

func _physics_process(delta):
	if Engine.is_editor_hint(): return
	adjusted_process.call(delta)

func _adjusted_process_low(delta):
	position += velocity*delta

func _adjusted_process(delta):
	velocity += acceleration * delta * 0.5
	init_pos += velocity*delta
	velocity += acceleration * delta * 0.5
	position = init_pos + sine_direction * sine_width * sin((STGGlobal.time(false) - start_time) * sine_freq)

func remove():
	# animations
	if lifespan: lifespan.free()
	queue_free()
