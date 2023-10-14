@tool
class_name STGBulletModifier extends Resource

enum TYPE{LOW, REGULAR, HIGH}

@export var index:int = 0
@export var outer_color:Color = Color.RED
@export var inner_color:Color = Color.WHITE
@export var type:TYPE = TYPE.REGULAR
@export var speed:float
@export var acceleration:float
@export var sine_freq:float
@export var sine_width:float
