@tool
class_name Laser2D extends Line2D

func _init():
	if !Engine.is_editor_hint(): return
	texture = load("res://addons/deranged_additions/loads/LaserGradient.tres")
	texture_mode = LINE_TEXTURE_STRETCH
	begin_cap_mode = LINE_CAP_ROUND
	end_cap_mode = LINE_CAP_ROUND

## Outer color for the laser beam.
@export var color_outer:Color = Color.RED:
	set(val):
		texture.gradient.set_color(0, val)
		texture.gradient.set_color(3, val)
		color_outer = val

## Inner color for the laser beam.
@export var color_inner:Color = Color.WHITE:
	set(val):
		texture.gradient.set_color(1, val)
		texture.gradient.set_color(2, val)
		color_inner = val
