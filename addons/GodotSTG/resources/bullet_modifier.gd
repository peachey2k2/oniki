class_name STGBulletModifier extends Resource

enum TYPE{LOW, REGULAR, HIGH}
enum TRIGGER_CHECK{EXITED, ENTERED}

@export var index:int = 0
@export var outer_color:Color = Color.RED
@export var inner_color:Color = Color.WHITE
@export var type:TYPE = TYPE.REGULAR
@export var speed:float
@export var acceleration:float
@export var lifespan:float = -1
@export var sine_freq:float
@export var sine_width:float
@export var zoned:STGBulletModifier
@export var trigger_check:TRIGGER_CHECK = TRIGGER_CHECK.EXITED

# this is automatically set at runtime. dw about it.
var id:int = -1
