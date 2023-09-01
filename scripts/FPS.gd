extends Label

var fps := 1
var start := Time.get_ticks_msec()

func _process(_delta: float) -> void:
	var end := Time.get_ticks_msec()
	if end - start < 1000:
		fps += 1
	else:
		start = Time.get_ticks_msec()
		text = "FPS: " + str(fps)
		fps = 1
