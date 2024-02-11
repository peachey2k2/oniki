extends Label

var next_beep:int
@onready var Audio = $AudioStreamPlayer

func _ready():
	STGGlobal.spell_changed.connect(Callable(self, "_on_spell_changed"))

func _physics_process(_delta):
	var time_left = int(GFS.Controller.timer.time_left)
	text = str(time_left)
	if time_left == next_beep:
		next_beep -= 1
		Audio.play()

func _on_spell_changed(_data):
	next_beep = 10
