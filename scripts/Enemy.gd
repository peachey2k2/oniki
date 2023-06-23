extends Area2D

const PRE_SPELL_WAIT_TIME = 1

@onready var BattleStats = $"/root/BattleStats"
@onready var BattleUI = $"../BattleUI"
@onready var BulletSpawner = preload("res://scenes/bullet_spawner.tscn")
@onready var Spawners = $"Spawners"
var BarCount:int
var Timeout:float
var stats:Dictionary
var bar:Dictionary
var spell:Dictionary
var spawner:Dictionary
var BulletSpawner_ins:Node

func _physics_process(delta):
	if Input.is_action_just_pressed("debug") && Spawners.get_child_count() == 0: #Q
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
					BulletSpawner_ins.position = spawner.get("offset")
					Spawners.add_child(BulletSpawner_ins)
					match spawner.get("type"):
						0:
							BulletSpawner_ins.arrange_bullets_circular(
								spawner.get("bullet_type"),
								spawner.get("bullet_color"),
								spawner.get("amount"),
								spawner.get("repeat"),
								spawner.get("tilt"),
								spawner.get("velocity"),
								spawner.get("distance"),
								spawner.get("delay")
							)
				await BattleUI.get_node("LifeBarContainer").bar_emptied
				monitoring = false

func _on_life_bar_container_bar_emptied():
	for i in Spawners.get_children():
		i.queue_free()
