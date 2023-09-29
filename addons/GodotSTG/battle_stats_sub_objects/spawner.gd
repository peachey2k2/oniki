@tool
class_name STGSpawner extends Resource

enum POS_TYPE{ABSOLUTE, RELATIVE}
enum TOWARDS{GENERIC, PLAYER}
enum TYPE{LOW, REGULAR, HIGH}

@export_group("Spawner")
@export var position:Vector2
@export var position_type:POS_TYPE
@export var towards:TOWARDS
@export var rotation_speed:float
@export var bullet_index:int
@export var bullet_outer_color:Color = Color.RED
@export var bullet_inner_color:Color = Color.WHITE
@export var bullet_type:TYPE = TYPE.REGULAR
var pool:Array
