extends Node

signal battle_start
signal shield_changed(value:int)
signal spell_name_changed(value:String)
signal bar_changed(value:int)
signal life_changed(values:Array[int], colors:Array[Color])
signal end_sequence
signal end_spell
signal end_battle

signal bar_emptied
signal damage_taken(new_amount:int)

@onready var bullet_template = preload("res://addons/GodotSTG/bullets/_template.tscn")
@onready var zone_template = preload("res://addons/GodotSTG/resources/zone.tscn")

var controller:Node
var settings:Array[Dictionary] = [
	{
		"name": "bullet_directory",
		"default": "res://addons/GodotSTG/bullets/default",
	},{
		"name": "collision_layer",
		"default": 2,
	},{
		"name": "pool_size",
		"default": 5000,
	}
]

var BULLET_DIRECTORY
var COLLISION_LAYER
var POOL_SIZE

var pool:Array[STGBullet]
var data_arr:Array[STGBulletData]

func _ready():
	for _setting in settings:
		set((_setting.get("name").to_upper()), ProjectSettings.get_setting("godotstg/" + _setting.get("name"), _setting.get("default")))

# further testing revealed that pooling is actually SLOWER, at least for my case.
# i'm either gonna remove the pooling system or make it toggleable and disabled by default.
func pool_all():
	await get_tree().process_frame # waiting to resolve a dumb race condition. #todo: fix this in a less horrible way
	for dir in DirAccess.get_files_at(BULLET_DIRECTORY):
		data_arr.append(load(BULLET_DIRECTORY + "/" + dir))
	for i in POOL_SIZE:
		var ins = bullet_template.instantiate()
		var spr = ins.get_child(0)
		pool.append(ins)

func get_bullet(idx:int) -> STGBullet:
	assert(pool.size() > 0, "Pool is out of bullets.")
	var bullet = pool[-1]
	pool.pop_back() 
	var data = data_arr[idx]
	bullet.get_child(1).shape = data.collision
	# we replace the texture and gradient with their duplicates, which is the
	# same as making them unique. this is done to prevent color/texture sharing
	bullet.get_child(0).texture = data.texture.duplicate()
	bullet.get_child(0).texture.gradient = data.texture.gradient.duplicate()
	bullet.collision_layer = COLLISION_LAYER
	return bullet

func repool(bullet:STGBullet):
	bullet.process_mode = Node.PROCESS_MODE_DISABLED
	bullet.hide()
	bullet.get_parent().remove_child(bullet)
	pool.append(bullet)
