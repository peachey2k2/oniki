extends Sprite2D

const NOTCH_COLOR = Color(Color.RED, 0.75)
const NOTCH_WIDTH = 1.5

@onready var Enemy = $".."

@export var count:int:
	set(val):
		count = val
		queue_redraw()

func _draw():
	var next_angle = 0
	for i in get_child_count():
		var length = deg_to_rad(Enemy.degrees[i]) / Enemy.spells[i].health
		for j in Enemy.spells[i].health:
			next_angle += length
			draw_line(
				(Vector2.UP * 91).rotated(next_angle),
				(Vector2.UP * 101).rotated(next_angle),
				NOTCH_COLOR,
				NOTCH_WIDTH
			)
