extends Area2D

func _on_area_entered(area):
	area.queue_free()
