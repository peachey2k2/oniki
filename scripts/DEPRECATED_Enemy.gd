extends Area2D

signal end_spell

const PRE_SPELL_WAIT_TIME = 1

@onready var BattleUI = $"/root/Battle/BattleUI"
@onready var BulletSpawner = preload("res://scenes/bullet_spawner.tscn")
@onready var Spawners = $"../Spawners"
@onready var TimeoutTimer = $"/root/Battle/BattleUI/Time/Timer"
@onready var SpellName = $"/root/Battle/BattleUI/SpellName"
@onready var Player = $"../Player"
@onready var Shield = $Shield
@onready var LifeBar = $"/root/Battle/BattleUI/LifeBarContainer"
var id:String
var BarCount:int
var Timeout:float
var stats:Dictionary
var bar:Dictionary
var spell:Dictionary
var spawner:Dictionary
var bullet:Dictionary
var BulletSpawner_ins:Node
var shield_state:int

func _process(delta):
	Shield.rotation += 3 * delta
	
func _ready():
	$"../BattleController".battle(Spawners, Player, self, GFS.BATTLE_RECT)
#	BattleUI.get_node("LifeBarContainer").connect("bar_emptied", Callable(self, "_on_bar_emptied"))
#	TimeoutTimer.connect("timeout", Callable(self, "_on_spell_timed_out"))
#
#	LifeBar.clear_health()
#	Player.position = GFS.bui_lerp(stats.get("player_pos"))
#	BattleUI.get_node("Graze").reset()
#	BattleUI.get_node("BarCount").text = str(stats.get("bar_count") - 1)
#	for i in stats.get("bar_count"):
#		bar = stats.get(i)
#		for j in bar.get("spell_count"):
#			spell = bar.get(j)
#			position = GFS.bui_lerp(spell.get("enemy_pos"))
#			change_shield(spell.get("shield"))
#			LifeBar.fill_health(spell.get("health"))
#			TimeoutTimer.start(spell.get("time"))
#			SpellName.text = spell.get("name")
#			await get_tree().create_timer(PRE_SPELL_WAIT_TIME, false).timeout
#			monitoring = true
#			for k in spell.get("spawner_count"):
#				spawner = spell.get(k).get("spawner")
#				bullet = spell.get(k).get("bullet")
#				BulletSpawner_ins = BulletSpawner.instantiate()
#				match spawner.get("pos_type"):
#					0: BulletSpawner_ins.position = GFS.bui_lerp(spawner.get("position"))
#					1: BulletSpawner_ins.position = GFS.bui_lerp(spawner.get("position")) + position
#				BulletSpawner_ins.rotation_speed = spawner.get("rotation_speed")
#				Spawners.add_child(BulletSpawner_ins)
#				match spawner.get("type"):
#					0: BulletSpawner_ins.circular(
#						bullet.get("bullet_type"),
#						bullet.get("bullet_color"),
#						bullet.get("init_angle"),
#						bullet.get("amount"),
#						bullet.get("repeat"),
#						bullet.get("tilt"),
#						bullet.get("speed"),
#						bullet.get("distance"),
#						bullet.get("stretch"),
#						bullet.get("delay"),
#						bullet.get("sleep"),
#						bullet.get("towards"),
#						bullet.get("acceleration"),
#						bullet.get("sine_freq"),
#						bullet.get("sine_width"),
#					)
#					1: BulletSpawner_ins.linear(
#						bullet.get("bullet_type"),
#						bullet.get("bullet_color"),
#						bullet.get("init_angle"),
#						bullet.get("amount"),
#						bullet.get("repeat"),
#						bullet.get("speed"),
#						GFS.bui_lerp(bullet.get("start_point")),
#						bullet.get("is_random"),
#						GFS.bui_lerp(bullet.get("gap")),
#						bullet.get("delay"),
#						bullet.get("sleep"),
#						bullet.get("bullet_angle"),
#						bullet.get("bullet_skew"),
#						bullet.get("towards"),
#						bullet.get("acceleration"),
#						bullet.get("sine_freq"),
#						bullet.get("sine_width"),
#					)
#			await self.end_spell
#			monitoring = false
#	GFS.end_battle()

func change_shield(shield:int):
	shield_state = shield
	match shield:
		0: Shield.modulate = Color.TRANSPARENT
		1: Shield.modulate = Color.RED

func _on_bar_emptied():
	for i in Spawners.get_children():
		i.queue_free()
	emit_signal("end_spell")

func _on_spell_timed_out():
	for i in Spawners.get_children():
		i.queue_free()
	emit_signal("end_spell")
