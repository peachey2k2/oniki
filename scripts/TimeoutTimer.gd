extends Label

var next_beep:int

func _ready():
	STGGlobal.spell_changed.connect(Callable(self, "_on_spell_changed"))

func _physics_process(_delta):
	var time_left = int(GFS.Controller.timer.time_left)
	text = str(time_left)
	if time_left == next_beep:
		next_beep -= 1
		SFX.TimerBeep.play()

func _on_spell_changed(_data):
	next_beep = 10
