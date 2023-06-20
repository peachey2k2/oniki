extends Label

func _physics_process(delta):
	text = str("%.f" % get_child(0).time_left)
	
