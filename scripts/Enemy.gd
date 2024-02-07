extends Area2D

@onready var Shield = $Shield
@onready var HealthBar = $Health

const PRE_SPELL_INVINCIBILITY := 1.4
const GHOST_TRANSITION_TIME := 0.1
const GHOST_MODULATE := Color(1, 1, 1, 0.6)

var id:String
var is_vulnerable:bool = false

var health:float:
	set(val):
		health = val
		var tw := create_tween()
		tw.set_trans(Tween.TRANS_QUAD) #quan
		tw.set_ease(Tween.EASE_OUT)
		tw.tween_property(HealthBar, "value", val/max_health, 0.15)
		
var max_health:
	set(val):
		max_health = val
		health = val
		HealthBar.count = max_health

func _on_battle_start():
	is_vulnerable = false
	ghost(true)

func _on_player_shoot():
	if is_vulnerable && has_overlapping_areas():
		if health != 0:
			health -= 1
			STGGlobal.update_health(health)

func _on_spell_changed(data:STGCustomData, life:int):
	max_health = life
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

