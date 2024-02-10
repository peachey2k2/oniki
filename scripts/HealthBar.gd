extends Sprite2D

const NOTCH_COLOR = Color.RED
const NOTCH_WIDTH = 1.5

@onready var Enemy = $".."

@export var count:int:
	set(val):
		count = val
		queue_redraw()

func _draw():
	var next_angle = 0
	for i in get_child_count():
		var length = deg_to_rad(get_child(0).radial_fill_degrees) / Enemy.spells[i].health
		for j in Enemy.spells[i].health:
			next_angle += length
			if i != 1: break
			draw_line(
				(Vector2.UP * 91).rotated(next_angle),
				(Vector2.UP * 101).rotated(next_angle),
				NOTCH_COLOR,
				NOTCH_WIDTH
			)
