@tool
class_name STGSpawner extends Resource

enum POS_TYPE{ABSOLUTE, RELATIVE}
enum TOWARDS{GENERIC, PLAYER}
enum TRIGGER_CHECK{EXITED, ENTERED}

@export_group("Spawner")
@export var position:Vector2
@export var position_type:POS_TYPE
@export var towards:TOWARDS
@export var rotation_speed:float

@export_group("Bullet")
@export var bullet:STGBulletModifier

@export_group("Zone")
@export var shape:Shape2D = null
@export var offset:Vector2 = Vector2(0, 0)
@export var trigger_check:TRIGGER_CHECK = TRIGGER_CHECK.EXITED
@export var new_bullet:STGBulletModifier

var pool:Array
