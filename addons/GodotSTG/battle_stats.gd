@tool
class_name STGStats extends Resource

func get_stats(id:String) -> Dictionary:
	return get(id)

@export var player_position:Vector2
@export var bars:Array[STGBar]
