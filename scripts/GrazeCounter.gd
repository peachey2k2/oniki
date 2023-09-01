extends Label

var graze := 0
var grazed := []

func _ready():
	grazed.resize(50)

func _on_area_entered(area):
	if !grazed.has(area):
		grazed[graze % 50] = area
		graze += 1
		text = str(graze)

func reset():
	graze = 0
	text = "0"
