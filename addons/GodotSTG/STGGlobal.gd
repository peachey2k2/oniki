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
		"name": "pool_size",
		"default": 5000,
	},{
		"name": "collision_layer",
		"default": 0b10,
	}
]

var BULLET_DIRECTORY
var POOL_SIZE
var COLLISION_LAYER
var ZONE_LAYER

#var pool:Array[STGBullet]
#var data_arr:Array[STGBulletData]
var bullet_list:Array[PackedScene]

func _init():
	for _setting in settings:
		set((_setting.get("name").to_upper()), ProjectSettings.get_setting("godotstg/" + _setting.get("name"), _setting.get("default")))

func _ready():
	for file in DirAccess.get_files_at(BULLET_DIRECTORY):
#		data_arr.append(load(BULLET_DIRECTORY + "/" + dir))
		bullet_list.append(load(BULLET_DIRECTORY + "/" + file))
	
	# global clocks cuz yeah
	clock_timer      = get_tree().create_timer(TIMER_START, false)
	clock_real_timer = get_tree().create_timer(TIMER_START, true)

# further testing revealed that pooling is actually SLOWER, at least for my case.
# i'm either gonna remove the pooling system or make it toggleable and disabled by default.
#func pool_all():
#	await get_tree().process_frame # waiting to resolve a dumb race condition. #todo: fix this in a less horrible way
#	for dir in DirAccess.get_files_at(BULLET_DIRECTORY):
#		data_arr.append(load(BULLET_DIRECTORY + "/" + dir))
#	for i in POOL_SIZE:
#		var ins = bullet_template.instantiate()
#		var spr = ins.get_child(0)
#		pool.append(ins)

func get_bullet(idx:int) -> STGBullet:
	var bullet = bullet_list[idx].instantiate()
#	assert(pool.size() > 0, "Pool is out of bullets.")
#	var bullet = pool[-1]
#	pool.pop_back()
#	var data = data_arr[idx]
#	bullet.get_child(1).shape = data.collision #no
	# we replace the texture and gradient with their duplicates, which is the
	# same as making them unique. this is done to prevent color/texture sharing
#	bullet.get_child(0).texture = data.texture.duplicate() #no
#	bullet.get_child(0).texture.gradient = data.texture.gradient.duplicate() #no
#	bullet.collision_layer = COLLISION_LAYER #no
	return bullet

#func repool(bullet:STGBullet):
#	bullet.process_mode = Node.PROCESS_MODE_DISABLED
#	bullet.hide()
#	bullet.get_parent().remove_child(bullet)
#	pool.append(bullet)

# global clocks
const TIMER_START = 10000000

var clock:float
var clock_real:float
var clock_timer:SceneTreeTimer
var clock_real_timer:SceneTreeTimer

# this will always return how much time has passed since the game started.
func time(count_while_paused:bool = true) -> float:
	if count_while_paused:
		return TIMER_START - clock_real_timer.get_time_left()
	else:
		return TIMER_START - clock_timer.get_time_left()
