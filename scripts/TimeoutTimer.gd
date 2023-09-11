extends Label


func _physics_process(_delta):
	text = str("%.f" % GFS.Controller.timer.time_left)
	
