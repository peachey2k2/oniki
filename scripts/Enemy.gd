extends Area2D

@onready var BattleStats = $"/root/BattleStats"
@onready var BattleUI = $"../BattleUI"
var BarCount:int
var Timeout:float
var stats:Dictionary
var bar:Dictionary
var spell:Dictionary
var BulletSpawner:Node

func _physics_process(delta):
	#print(get_child_count())
	if Input.is_action_just_pressed("debug") && BulletSpawner == null: #Q
		stats = BattleStats.enemy
		BulletSpawner = preload("res://scenes/bullet_spawner.tscn").instantiate()
		add_child(BulletSpawner)
		BattleUI.get_node("BarCount").text = str(stats.get("bar_count") - 1)
		for i in stats.get("bar_count"):
			bar = stats.get(i)
			for j in bar.get("spell_count"):
				spell = bar.get(j)
				$"../BattleUI/LifeBarContainer".fillHealth(spell.get("health"))
				BattleUI.get_node("Time/Timer").start(spell.get("time"))
				BattleUI.get_node("SpellName").text = spell.get("name")
				await BulletSpawner.arrange_bullets_circular(
					spell.get("amount"),
					spell.get("repeat"),
					spell.get("tilt"),
					spell.get("velocity"),
					spell.get("distance"),
					spell.get("delay"),
					delta
				)

func _on_life_bar_container_bar_emptied():
	BulletSpawner.queue_free()
