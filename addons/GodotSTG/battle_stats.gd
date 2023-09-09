@tool
class_name STGStats extends PackedDataContainer

enum {STATIC, RANDOM}
enum {CIRCULAR, LINEAR}
enum {ABSOLUTE, RELATIVE}
enum {SMALL, MEDIUM, LARGE, XLARGE}


func get_stats(id:String) -> Dictionary:
	return get(id)

@export var player_position:Vector2
@export var bars:Array[STGBar]
