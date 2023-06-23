extends Label

func _physics_process(_delta):
	text = str("%.f" % get_child(0).time_left)
	
