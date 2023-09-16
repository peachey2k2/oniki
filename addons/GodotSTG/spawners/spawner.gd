@tool
class_name STGSpawnerNode extends Node2D

var rotation_speed:float
var bullet:STGBullet
var pool:Array
var spawn_bullet:Callable
var color_outer:Color
var color_inner:Color
var bullet_type:int

func _ready():
	var type_string
	match bullet_type:
		0: type_string = "low"
		1: type_string = "regular"
		2: type_string = "high"
	spawn_bullet = Callable(self, "_spawn_" + type_string)

func _physics_process(delta):
	if Engine.is_editor_hint(): return
	rotate(rotation_speed*delta)

func _spawn_low(pos, vel, _acc):
	var ins = get_bullet()
	ins.process_mode = Node.PROCESS_MODE_INHERIT
	ins.called_low(pos, vel, color_outer, color_inner)
	add_child(ins)
	ins.show()

func _spawn_regular(pos, vel, acc):
	var ins = get_bullet()
	ins.process_mode = Node.PROCESS_MODE_INHERIT
	ins.called(pos, vel, acc, color_outer, color_inner)
	add_child(ins)
	ins.show()

func get_bullet():
	var pool_size = pool.size()
	assert(pool_size > 0, "Pool is out of bullets.")
	var out = pool[pool_size-1]
	pool.pop_back()
	out.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	out.show()
	return out

func remove():
	for _bullet in get_children():
		_bullet.remove()
	queue_free()
