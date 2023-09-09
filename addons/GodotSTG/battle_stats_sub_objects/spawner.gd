@tool
class_name STGSpawner extends PackedDataContainer

enum POS_TYPE{ABSOLUTE, RELATIVE}
enum TOWARDS{GENERIC, PLAYER}

@export_group("Spawner")
@export var position:Vector2
@export var position_type:POS_TYPE
@export var towards:TOWARDS
@export var rotation_speed:int
@export var bullet_index:int
var pool:Array
