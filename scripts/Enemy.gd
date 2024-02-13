extends Area2D

@onready var Shield = $Shield
@onready var HealthBar = $HealthBar

const SPELL_BAR = preload("res://scenes/misc/spell_bar.tscn")

const PRE_SPELL_INVINCIBILITY := 1.4
const GHOST_TRANSITION_TIME := 0.1
const GHOST_MODULATE := Color(1, 1, 1, 0.6)

var id:String
var is_vulnerable:bool = false
var spells:Array[STGCustomData]
var degrees:Array[float]

var health:float:
	set(val):
		health = val
		var tw := create_tween()
		tw.tween_property(HealthBar.get_child(0), "value", val/max_health, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD) #quan
		if val == 0:
			HealthBar.move_child(HealthBar.get_child(0), -1)

var max_health:
	set(val):
		max_health = val
		health = val
		HealthBar.count = max_health

func _ready():
	STGGlobal.battle_start.connect(Callable(self, "_on_battle_start"))
	STGGlobal.bar_changed.connect(Callable(self, "_on_bar_changed"))
	STGGlobal.spell_changed.connect(Callable(self, "_on_spell_changed"))
	STGGlobal.end_spell.connect(Callable(self, "_on_end_spell"))

func _on_battle_start():
	is_vulnerable = false
	ghost(true)

func _on_bar_changed(value):
	if value < 0: return
	#for spell in GFS.Controller.stats.bars[GFS.Controller.stats.bars.size() - value - 1].spells:
	spells = []
	degrees = []
	for i in HealthBar.get_children():
		i.free()
	var spellcard_count := 0
	var nonspell_count := 0
	for i in GFS.Controller.stats.bars[GFS.Controller.stats.bars.size() - value - 1].spells:
		var data:STGCustomData = i.custom_data
		var ins = SPELL_BAR.instantiate()
		spells.append(data)
		HealthBar.add_child(ins)
		ins.tint_progress = data.bar_color
		if data.name.is_empty():
			ins.is_spellcard = false
			nonspell_count += 1
		else:
			ins.is_spellcard = true
			spellcard_count += 1
	if nonspell_count == 0 || spellcard_count == 0:
		var next_angle := 360.0
		var length := 360.0 / HealthBar.get_child_count()
		for i in range(HealthBar.get_child_count() - 1, -1, -1):
			var bar = HealthBar.get_child(i)
			bar.radial_initial_angle = next_angle
			bar.radial_fill_degrees = length
			degrees.push_front(length)
			next_angle -= length
	else:
		var next_angle := 360.0
		var s_length := (30.0 + 35.0 * spellcard_count) / spellcard_count
		var n_length := (330.0 - 35.0 * spellcard_count) / nonspell_count
		for i in range(HealthBar.get_child_count() - 1, -1, -1):
			var bar = HealthBar.get_child(i)
			bar.radial_initial_angle = next_angle
			if bar.is_spellcard:
				bar.radial_fill_degrees = s_length
			else:
				bar.radial_fill_degrees = n_length
			degrees.push_front(bar.radial_fill_degrees)
			next_angle -= bar.radial_fill_degrees

func _on_player_shoot():
	if is_vulnerable && has_overlapping_areas():
		if health != 0:
			health -= 1
			STGGlobal.update_health(health)

func _on_spell_changed(data:STGCustomData):
	max_health = data.health
	ghost(true)
	await get_tree().create_timer(PRE_SPELL_INVINCIBILITY, false).timeout
	match data.shield_type:
		0:
			Shield.hide()
			unghost()
			is_vulnerable = true
		1:
			Shield.hide()
		2:
			Shield.show()
			unghost()

func _on_end_spell():
	is_vulnerable = false

func ghost(instant := false):
	if instant:
		modulate = GHOST_MODULATE
	else:
		var tw := create_tween()
		tw.tween_property(self, "modulate", GHOST_MODULATE, GHOST_TRANSITION_TIME)

func unghost(instant := false):
	if instant:
		modulate = Color.WHITE
	else:
		var tw := create_tween()
		tw.tween_property(self, "modulate", Color.WHITE, GHOST_TRANSITION_TIME)

