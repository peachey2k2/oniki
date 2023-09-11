@tool
class_name BattleController extends Node2D

const PRE_SPELL_WAIT_TIME = 1

@export_category("BattleController")
@export var stats:STGStats

var life:int
var shield_state:int
var _arena_rect:Rect2
var _spawner_container:Node2D
var tree:SceneTree
var timer:Timer

func _ready():
	tree = get_tree()
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(Callable(self, "_on_spell_timed_out"))
	STGGlobal.bar_emptied.connect(Callable(self, "_on_bar_emptied"))
	add_child(timer)

func lerp4arena(weight:Vector2) -> Vector2:
	return Vector2(
		lerp(_arena_rect.position.x, _arena_rect.end.x, weight.x),
		lerp(_arena_rect.position.y, _arena_rect.end.y, weight.y)
	)

func start(spawner_container:Node2D, player:Node2D, enemy:Node2D, arena_rect:Rect2):
	STGGlobal.controller = self
	STGGlobal.battle_start.emit()
	_spawner_container = spawner_container
	_arena_rect = arena_rect
	var bar_count = stats.bars.size()
	STGGlobal.bar_changed.emit(bar_count)
	life = 0
	player.position = lerp4arena(stats.player_position)
	for curr_bar in stats.bars:
		for curr_spell in curr_bar.spells:
			enemy.position = lerp4arena(curr_spell.enemy_pos)
			change_shield(shield_state)
			STGGlobal.life_changed.emit(curr_spell.health)
			timer.wait_time = curr_spell.time
			timer.start()
			STGGlobal.spell_name_changed.emit(curr_spell.name)
			await tree.create_timer(PRE_SPELL_WAIT_TIME, false).timeout
			enemy.monitoring = true
			for curr_sequence in curr_spell.sequences:
				#AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
				for curr_spawner in curr_sequence.spawners:
					var spawner = STGSpawnerNode.new()
					spawner.pool = STGGlobal.pools[curr_spawner.bullet_index]
					spawner_container.add_child(spawner)
					match curr_spawner.position_type:
						0: spawner.position = lerp4arena(curr_spawner.position)
						1: spawner.position = lerp4arena(curr_spawner.position) + enemy.position
					spawner.rotation_speed = curr_spawner.rotation_speed
					curr_spawner.spawn(spawner)
			await STGGlobal.end_spell
			enemy.monitoring = false
		bar_count -= 1
		STGGlobal.bar_changed.emit(bar_count)
	STGGlobal.end_battle.emit()

func change_shield(shield:int):
	shield_state = shield
	STGGlobal.shield_changed.emit(shield)

func _on_timer_timeout():
	pass

func _on_bar_emptied():
	for i in _spawner_container.get_children():
		i.remove()
	STGGlobal.end_spell.emit()

func _on_spell_timed_out():
	for i in _spawner_container.get_children():
		i.remove()
	STGGlobal.end_spell.emit()
