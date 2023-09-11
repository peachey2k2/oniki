extends Node

signal battle_start
signal shield_changed(value:int)
signal spell_name_changed(value:String)
signal bar_changed(value:int)
signal life_changed(value:int)
signal end_spell
signal end_battle

signal bar_emptied

@onready var bullet_template = preload("res://addons/GodotSTG/bullets/_template.tscn")

var controller:Node
var settings:Array[Dictionary] = [
	{
		"name": "bullet_directory",
		"default": "res://addons/GodotSTG/bullets/default/",
		"type": TYPE_STRING_NAME,
		"hint": PROPERTY_HINT_DIR,
		"hint_string": ""
	},{
		"name": "collision_layer",
		"default": 2,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_LAYERS_2D_PHYSICS,
		"hint_string": ""
	}
]

var BULLET_DIRECTORY
var COLLISION_LAYER

var pools:Array[Array]

func _ready():
	for _setting in settings:
		set((_setting.get("name").to_upper()), ProjectSettings.get_setting("godotstg/" + _setting.get("name"), _setting.get("default")))
	pool_all()

func pool_all():
	var bullet_list:Array[STGPackedBulletContainer]
	for dir in DirAccess.get_files_at(BULLET_DIRECTORY):
		bullet_list.append(load(BULLET_DIRECTORY + dir))
	pools.resize(bullet_list.size())
	for i in bullet_list.size():
		var bullet_data = bullet_list[i]
		var bullet = bullet_constructor(bullet_data)
		bullet_pool(bullet, bullet_data.pool_size, i)

func bullet_constructor(data:STGPackedBulletContainer) -> STGBullet:
	var bullet = bullet_template.instantiate()
	var outer = bullet.get_child(0)
	var inner = bullet.get_child(1)
	var collision = bullet.get_child(2)
	collision.shape = data.collision
	bullet.collision_layer = COLLISION_LAYER
	outer.texture = data.outer_texture
	inner.texture = data.inner_texture
	outer.modulate = data.outer_color
	inner.modulate = data.inner_color
	outer.scale = data.outer_scale * Vector2(1, 1)
	inner.scale = data.inner_scale * Vector2(1, 1)
	return bullet

func bullet_pool(bullet:STGBullet, size:int, i:int):
	bullet.index = i
	var pool = pools[i]
	pool.append(bullet)
	for j in size-1:
		pool.append(bullet.duplicate())

func _physics_process(delta):
	print(pools[0].size())

func repool(bullet:STGBullet):
	bullet.process_mode = Node.PROCESS_MODE_DISABLED
	bullet.hide()
	bullet.get_parent().remove_child(bullet)
	pools[bullet.index].append(bullet)
