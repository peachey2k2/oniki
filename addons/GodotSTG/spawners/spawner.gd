@tool
class_name STGSpawnerNode extends Node2D

var rotation_speed:float
var bullet:STGBullet
var pool:Array
var spawn_bullet:Callable

func _ready():
	spawn_bullet = Callable(self, "_spawn_regular")

func _physics_process(delta):
	if Engine.is_editor_hint(): return
	rotate(rotation_speed*delta)

func _spawn_regular(pos, vel, acc):
	var ins = get_bullet()
	ins.position = pos
	ins.velocity = vel
	ins.acceleration = acc
	ins.process_mode = Node.PROCESS_MODE_INHERIT
	ins.called()
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
