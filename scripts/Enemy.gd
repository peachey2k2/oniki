extends Area2D

@onready var Shield = $Shield
@onready var HealthBar = $Health

const PRE_SPELL_INVINCIBILITY := 1.5

var id:String
var is_vulnerable:bool = false

var health:float:
	set(val):
		health = val
		HealthBar.value = val/max_health
		
var max_health:
	set(val):
		max_health = val
		health = val
		HealthBar.count = max_health

#func _ready():
	#Shield = $Shield
	#STGGlobal.shield_changed.connect(Callable(self, "_on_shield_changed"))

func _on_player_shoot():
	if is_vulnerable && has_overlapping_areas():
		if health != 0:
			health -= 1
			STGGlobal.update_health(health)

func _on_spell_changed(_data:STGCustomData, life:int):
	max_health = life
	await get_tree().create_timer(PRE_SPELL_INVINCIBILITY, false).timeout
	is_vulnerable = true

func _on_end_spell():
	is_vulnerable = false
