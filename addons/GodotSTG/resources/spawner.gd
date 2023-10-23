@tool
class_name STGSpawner extends Resource

enum POS_TYPE{ABSOLUTE, RELATIVE}
enum TOWARDS{GENERIC, PLAYER}

@export_group("Spawner")
@export var position:Vector2
@export var position_type:POS_TYPE
@export var towards:TOWARDS
@export var rotation:float
@export var rotation_speed:float

@export_group("Bullet")
@export var bullet:STGBulletModifier

@export_group("Zone")
@export var shape:Shape2D = null
@export var offset:Vector2 = Vector2(0, 0)

var real_pos:Vector2

func spawn():
	if Engine.is_editor_hint(): return
	bdata = STGGlobal.bdata[bullet.index]
	tex = STGGlobal.textures[bullet.id]
	if position_type:
		real_pos = position + STGGlobal.controller.enemy.position
	else:
		real_pos = position
	_spawn()

func _spawn():
	pass

var bdata:STGBulletData
var tex:Texture2D

func spawn_bullet(pos, vel, acc):
	var _bdata = bdata.duplicate()
	_bdata.position = pos
	_bdata.velocity = vel
	_bdata.acceleration = acc
	_bdata.lifespan = -1
	_bdata.texture = tex
	STGGlobal.create_bullet(_bdata)
