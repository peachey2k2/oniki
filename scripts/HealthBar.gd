extends TextureProgressBar

const CENTER = Vector2(128, 128)
const NOTCH_COLOR = Color.RED
const NOTCH_WIDTH = 1.5

@export var count:int:
	set(val):
		count = val
		queue_redraw()

func _draw():
	var topic_aunt = 2 * PI / count
	for i in count:
		var angle = i * topic_aunt
		draw_line(
			CENTER + (Vector2.UP * 91).rotated(angle),
			CENTER + (Vector2.UP * 101).rotated(angle),
			NOTCH_COLOR,
			NOTCH_WIDTH
		)
