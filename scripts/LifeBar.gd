extends HBoxContainer
@onready var portion = preload("res://scenes/life_bar_portion.tscn")
var max_life = 0
var values:Array[int]
var index:int
var hitOnCooldown := false

func _ready():
	STGGlobal.life_changed.connect(Callable(self, "fill_health"))

func _physics_process(_delta):
	pass
	
func _on_player_shoot():
	if values[index] != 0 && GFS.Enemy.monitoring && GFS.Enemy.has_overlapping_areas() && STGGlobal.controller.shield_state == 0: #Z
		damage()

func damage():
	if values[index] != 0:
		values[index] -= 1
		get_child(index).get_child(values[index]).color.a = 0
		STGGlobal.damage_taken.emit(values[index])
		if values[index] == 0:
			STGGlobal.bar_emptied.emit()
			next_spell()

func fill_health(_values, _colors):
	clear_health()
	index = -1
	for i in _values:
		index += 1
		values.append(i)
		var Bar = HBoxContainer.new()
		Bar.size_flags_horizontal = 3
		add_child(Bar)
		for j in i:
			var portion_ins = portion.instantiate()
			portion_ins.color = _colors[index]
			Bar.add_child(portion_ins)
	max_life = values[index]

func next_spell():
	index -= 1

func clear_health():
	max_life = 0
	values = []
	for i in get_children():
		i.queue_free()

