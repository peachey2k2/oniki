extends Area2D

func _physics_process(_delta):
	for area in get_overlapping_areas():
		var area_pos = area.position + Vector2(-440, -440)
		if abs(area_pos.x) > abs(area_pos.y):
			area.velocity.x *= -1
			area.position.x = area.last_pos.x
		if abs(area_pos.y) > abs(area_pos.x):
			area.velocity.y *= -1
			area.position.y = area.last_pos.y
