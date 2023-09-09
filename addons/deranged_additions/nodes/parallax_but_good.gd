## Oversimplified and standalone node for parallax scrolling.
@tool
extends TextureRect

## How much the node will move per second.
@export var scroll_speed:Vector2 = Vector2(0, 0)
## How many more copies of the texture there will be on each side. Setting this to 0 means the amount will just be enough to seamlessly wrap. Increase if you see blank spaces near screen edges.
@export var extra_copies:int = 1:
	set = set_extra_copies
@onready var texture_size:Vector2
@onready var screen_size:Vector2

func _enter_tree():
	pass

func _ready():
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_TILE
	_set_texture(texture)


func _set_texture(value:Texture2D):
	texture_size = value.get_size()
	screen_size = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)
	size = Vector2(
		floor(screen_size.x / texture_size.x + extra_copies*2 + 2),
		floor(screen_size.y / texture_size.y + extra_copies*2 + 2)
	) * texture_size

func _set(property, value):
	if property == "texture":
		_set_texture(value)

func set_extra_copies(value):
	extra_copies = value
	_set_texture(texture)

func _physics_process(delta):
	if !Engine.is_editor_hint():
		position += scroll_speed * delta
		position = Vector2(
			wrap(position.x, -texture_size.x * (extra_copies+1), -texture_size.x * extra_copies),
			wrap(position.y, -texture_size.y * (extra_copies+1), -texture_size.y * extra_copies)
		)

