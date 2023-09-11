extends HBoxContainer
@onready var portion = preload("res://scenes/life_bar_portion.tscn")
var maxLife = 0
var currLife = 0
var hitOnCooldown := false

func _ready():
	STGGlobal.life_changed.connect(Callable(self, "fill_health"))

func _physics_process(_delta):
	pass
	
func _on_player_shoot():
	if currLife != 0 && GFS.Enemy.monitoring && GFS.Enemy.has_overlapping_areas() && STGGlobal.controller.shield_state == 0: #Z
		currLife -= 1
		get_child(currLife).color.a = 0
		if currLife == 0:
			STGGlobal.bar_emptied.emit()
			fill_health(currLife)

func fill_health(lifeInput):
	clear_health()
	maxLife = lifeInput
	currLife = lifeInput
	for i in range(lifeInput):
		var portion_ins = portion.instantiate()
		add_child(portion_ins)

func clear_health():
	maxLife = 0
	currLife = 0
	for i in get_children():
		i.queue_free()

