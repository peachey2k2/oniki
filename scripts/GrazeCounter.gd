extends Label

var graze := 0
var grazed := []

func _ready():
	$"../../Player/GrazeDetection".connect("area_entered",Callable(self,"_on_area_entered"))
	grazed.resize(50)

func _on_area_entered(area):
	if !grazed.has(area):
		grazed[graze % 50] = area
		graze += 1
		text = str(graze)
