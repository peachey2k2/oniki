@tool
class_name STGSpawnerNode extends Node2D

var spawn_bullet:Callable
var data:STGSpawner

var area:Area2D
var coll:CollisionShape2D

func _ready():
	
	# configuring the callable. there are different "spawn" functions with increased
	# complexity so we don't run calculations for stuff that we won't need.
	var type_string
	match data.bullet.type:
		0: type_string = "low"
		1: type_string = "regular"
		2: type_string = "high"
	spawn_bullet = Callable(self, "_spawn_" + type_string)
	
	# configuring the zone logic
	area = STGGlobal.zone_template.instantiate()
	coll = area.get_child(0)
	coll.shape = data.shape
	add_child(area)
	if data.trigger_check == 0:
		area.area_exited.connect(Callable(self, "_zone_triggered"))
	else:
		area.area_entered.connect(Callable(self, "_zone_triggered"))

func _zone_triggered(bullet):
	if !(bullet is STGBullet): return
	bullet.modify(null, null, null, data.new_bullet.outer_color, data.new_bullet.inner_color)

func _physics_process(delta):
	if Engine.is_editor_hint(): return
	rotate(data.rotation_speed*delta)

func _spawn_low(pos, vel, _acc):
	var ins = STGGlobal.get_bullet(data.bullet.index)
	ins.called_low(pos, vel, data.bullet.outer_color, data.bullet.inner_color)
	add_child(ins)
	ins.show()

func _spawn_regular(pos, vel, acc):
	var ins = STGGlobal.get_bullet(data.bullet.index)
	ins.called(pos, vel, acc, data.bullet.outer_color, data.bullet.inner_color)
	add_child(ins)
	ins.show()

func remove():
	for _bullet in get_children():
		if _bullet is STGBullet:
			_bullet.remove()
	queue_free()
