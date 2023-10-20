@tool
class_name STGSpawnerNode extends Node2D

var spawn_bullet:Callable
var data:STGSpawner

var area:Area2D
var coll:CollisionShape2D

func _ready():
	
	rotation_degrees = data.rotation
	
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
	area.collision_mask = STGGlobal.COLLISION_LAYER
	coll = area.get_child(0)
	coll.shape = data.shape
	add_child(area)
	area.area_exited.connect(Callable(self, "_zone_exited"))
	area.area_entered.connect(Callable(self, "_zone_entered"))

func _zone_exited(area):
	if !(area is STGBullet) || !(area.data.zoned) || area.data.trigger_check != 0: return
	area.data = area.data.zoned
	area.modify(area.data)

func _zone_entered(area):
	if !(area is STGBullet) || !(area.data.zoned) || area.data.trigger_check != 1: return
	area.data = area.data.zoned
	area.modify(area.data)

func _physics_process(delta):
	if Engine.is_editor_hint(): return
	rotate(data.rotation_speed*delta)

func _spawn_low(pos, vel, _acc):
	var ins = STGGlobal.get_bullet(data.bullet.index)
	ins.called_low(pos, vel, data.bullet.outer_color, data.bullet.inner_color)
	ins.data = data.bullet
	add_child(ins)
	ins.show()

func _spawn_regular(pos, vel, acc):
	var ins = STGGlobal.get_bullet(data.bullet.index)
	ins.called(pos, vel, acc, data.bullet.outer_color, data.bullet.inner_color)
	ins.data = data.bullet
	add_child(ins)
	ins.show()

func remove():
	for _bullet in get_children():
		if _bullet is STGBullet:
			_bullet.remove()
	get_tree().create_timer(5, false)
	queue_free()
