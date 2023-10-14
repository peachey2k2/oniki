@tool
class_name STGSpell extends Resource

enum SHIELD{NONE, RED}
enum MOVEMENT{STATIC, RANDOM}

@export var name:String
@export var health:int
@export var time:int
@export var bar_color:Color = Color.WHITE
@export var enemy_pos:Vector2
@export var enemy_movement:MOVEMENT
@export var shield:SHIELD
@export var randomize_sequences:bool = false
@export var sequences:Array[STGSequence]
