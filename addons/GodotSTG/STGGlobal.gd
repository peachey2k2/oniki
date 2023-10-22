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
@onready var area_template = preload("res://addons/GodotSTG/resources/shared_area.tscn")

var controller:Node
var settings:Array[Dictionary] = [
	{
		"name": "bullet_directory",
		"default": "res://addons/GodotSTG/bullets/default",
	},{
		"name": "collision_layer",
		"default": 0b10,
	}
]

#settings
var BULLET_DIRECTORY
var COLLISION_LAYER

var bdata:Array[STGBulletData]
var textures:Array[Texture2D]
var bullet_count:int = 0
var shared_area:Area2D:
	set(val):
		area_rid = val.get_rid()
		shared_area = val
		shared_area.collision_layer = COLLISION_LAYER
var area_rid:RID
var b:Array[STGBulletData]

const TIMER_START = 10000000
var clock:float
var clock_real:float
var clock_timer:SceneTreeTimer
var clock_real_timer:SceneTreeTimer

#writes settings into variables for future use
func _init():
	for _setting in settings:
		set((_setting.get("name").to_upper()), ProjectSettings.get_setting("godotstg/" + _setting.get("name"), _setting.get("default")))

func _ready():
	for file in DirAccess.get_files_at(BULLET_DIRECTORY):
		bdata.append(load((BULLET_DIRECTORY + "/" + file).trim_suffix(".remap"))) # builds use .remap extension so that is trimmed here
		# you can look at this issue for more info: https://github.com/godotengine/godot/issues/66014
		# also this will probably change in a later release for the engine
	
	# global clocks cuz yeah
	clock_timer      = get_tree().create_timer(TIMER_START, false)
	clock_real_timer = get_tree().create_timer(TIMER_START, true)

# i got the idea on how to optimize this from this nice devlog. it's pretty clean and detailed.
# also their game looks pretty cool too, so check it out if you have the time.
# https://worldeater-dev.itch.io/bittersweet-birthday/devlog/210789/howto-drawing-a-metric-ton-of-bullets-in-godot
func create_bullet(data:STGBulletData):
#	var bullet = bullet_list[idx].instantiate()
	var t = Transform2D(0, data.position)
#	t.origin = data.position
	var shape_rid = PhysicsServer2D.circle_shape_create()
	PhysicsServer2D.shape_set_data(shape_rid, data.collision_radius)
	PhysicsServer2D.area_add_shape(area_rid, shape_rid, t)
	b.append(data)

func _physics_process(delta):
	for i in b.size():
		var blt = b[i]
		var t = Transform2D(0, blt.position)
#		t.origin = blt.position
		blt.velocity += blt.acceleration * delta * 0.5
		blt.position += blt.velocity * delta
		blt.velocity += blt.acceleration * delta * 0.5
		PhysicsServer2D.area_set_shape_transform(area_rid, i, t)

func create_texture(mod:STGBulletModifier):
	if mod.id != -1: return #todo: also check whether this exact texture is already saved (same index and colors)
	var tex:Texture2D = bdata[mod.index].texture.duplicate() # lol
	tex.gradient = tex.gradient.duplicate()
	tex.gradient.colors = [mod.inner_color, mod.inner_color, mod.outer_color, mod.outer_color, Color.TRANSPARENT]
	mod.id = textures.size()
	textures.append(tex)

# this will always return how much time has passed since the game started.
func time(count_pauses:bool = true) -> float:
	if count_pauses: return TIMER_START - clock_real_timer.get_time_left()
	else:            return TIMER_START - clock_timer     .get_time_left()
