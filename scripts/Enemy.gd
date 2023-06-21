extends Area2D

@onready var BattleStats = $"/root/BattleStats"
@onready var BattleUI = $"../BattleUI"
@onready var BulletSpawner = preload("res://scenes/bullet_spawner.tscn")
var BarCount:int
var Timeout:float
var stats:Dictionary
var bar:Dictionary
var spell:Dictionary
var spawner:Dictionary
var BulletSpawner_ins:Node

const PRE_SPELL_WAIT_TIME = 1

func _physics_process(delta):
	#print(get_child_count())
	if Input.is_action_just_pressed("debug") && get_child_count() <= 2: #Q
		stats = BattleStats.enemy
		BattleUI.get_node("BarCount").text = str(stats.get("bar_count") - 1)
		for i in stats.get("bar_count"):
			bar = stats.get(i)
			for j in bar.get("spell_count"):
				spell = bar.get(j)
				$"../BattleUI/LifeBarContainer".fillHealth(spell.get("health"))
				BattleUI.get_node("Time/Timer").start(spell.get("time"))
				BattleUI.get_node("SpellName").text = spell.get("name")
				await get_tree().create_timer(PRE_SPELL_WAIT_TIME).timeout
				monitoring = true
				for k in spell.get("spawner_count"):
					spawner = spell.get(k)
					BulletSpawner_ins = BulletSpawner.instantiate()
					add_child(BulletSpawner_ins)
					await BulletSpawner_ins.arrange_bullets_circular(
						spawner.get("amount"),
						spawner.get("repeat"),
						spawner.get("tilt"),
						spawner.get("velocity"),
						spawner.get("distance"),
						spawner.get("delay"),
						delta
					)
				monitoring = false

func _on_life_bar_container_bar_emptied():
	BulletSpawner.queue_free()
