extends Label

var graze := 0:
	set(val):
		graze = val
		text = str(val)

var grazed := []

func _ready():
	STGGlobal.battle_start.connect(Callable(self, "reset"))
	STGGlobal.graze.connect(Callable(self, "_on_graze"))

func reset():
	graze = 0
	text = "0"

func _on_graze(_bullet):
	graze += 1
