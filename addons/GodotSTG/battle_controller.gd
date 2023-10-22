@tool
class_name BattleController extends Node2D

@export_category("BattleController")
@export var stats:STGStats

var life:int
var shield_state:int
var _arena_rect:Rect2
var _spawner_container:Node2D
var tree:SceneTree
var timer:Timer
var is_spell_over:bool

var hp_threshold:int
var time_threshold:int

var player:Node2D
var enemy:Node2D

func _ready():
	if Engine.is_editor_hint(): return
	tree = get_tree()
	timer = Timer.new()
	timer.one_shot = true
	STGGlobal.end_sequence.connect(Callable(self, "_on_end_sequence"))
	timer.timeout.connect(Callable(self, "_on_spell_timed_out"))
	STGGlobal.bar_emptied.connect(Callable(self, "_on_bar_emptied"))
	STGGlobal.damage_taken.connect(Callable(self, "_on_damage_taken"))
#	STGGlobal.changed.connect(Callable(self, ))
	add_child(timer)

func lerp4arena(weight:Vector2) -> Vector2:
	return Vector2(
		lerp(_arena_rect.position.x, _arena_rect.end.x, weight.x),
		lerp(_arena_rect.position.y, _arena_rect.end.y, weight.y)
	)

# TODO: fix this. please.
func start(spawner_container:Node2D, arena_rect:Rect2):
	assert(player, "\"player\" has to be set in order for start() to work.")
	assert(enemy, "\"enemy\" has to be set in order for start() to work.")	
	STGGlobal.shared_area = STGGlobal.area_template.instantiate()
	add_child(STGGlobal.shared_area)
	STGGlobal.controller = self
	STGGlobal.battle_start.emit()
	_spawner_container = spawner_container
	_arena_rect = arena_rect
	var bar_count = stats.bars.size()
	STGGlobal.bar_changed.emit(bar_count)
	life = 0
	player.position = lerp4arena(stats.player_position)
	for curr_bar in stats.bars:
		emit_life(curr_bar)
		for curr_spell in curr_bar.spells:
			is_spell_over = false
			enemy.position = lerp4arena(curr_spell.enemy_pos)
			change_shield(curr_spell.shield)
			timer.wait_time = curr_spell.time
			timer.start()
			STGGlobal.spell_name_changed.emit(curr_spell.name)
			enemy.monitoring = true
			for seq in curr_spell.sequences:
				for spw in seq.spawners:
					var blt = spw.bullet
					while true:
						STGGlobal.create_texture(blt)
						if !(blt.zoned): break
						else:            blt = blt.zoned
			while !is_spell_over:
				for curr_sequence in curr_spell.sequences:
					if is_spell_over: break
					hp_threshold = curr_sequence.end_at_hp
					time_threshold = curr_sequence.end_at_time
					await tree.create_timer(curr_sequence.wait_before, false).timeout
					for curr_spawner in curr_sequence.spawners:
						var spawner = STGSpawnerNode.new()
						spawner.data = curr_spawner
						spawner_container.add_child(spawner)
						match curr_spawner.position_type:
							0: spawner.position = lerp4arena(curr_spawner.position)
							1: spawner.position = lerp4arena(curr_spawner.position) + enemy.position
						curr_spawner.spawn(spawner)
					await STGGlobal.end_sequence
			await STGGlobal.end_spell
			enemy.monitoring = false
		bar_count -= 1
		STGGlobal.bar_changed.emit(bar_count)
	STGGlobal.end_battle.emit()

func _physics_process(delta):
	queue_redraw()

func _draw():
	for blt in STGGlobal.b:
		draw_texture(blt.texture, blt.position - blt.texture.get_size() * 0.5)

func emit_life(_bar):
	var values:Array
	var colors:Array
	for i in _bar.spells:
		values.push_front(i.health)
		colors.push_front(i.bar_color)
	STGGlobal.life_changed.emit(values, colors)

func change_shield(_shield:int):
	shield_state = _shield
	STGGlobal.shield_changed.emit(_shield)

func _on_timer_timeout():
	pass

func _on_bar_emptied():
	for i in _spawner_container.get_children():
		i.remove()
	is_spell_over = true
	STGGlobal.end_sequence.emit()
	STGGlobal.end_spell.emit()

func _on_spell_timed_out():
	for i in _spawner_container.get_children():
		i.remove()
	is_spell_over = true
	STGGlobal.end_sequence.emit()
	STGGlobal.end_spell.emit()

func _on_end_sequence():
	for i in _spawner_container.get_children():
		i.remove()

func _on_damage_taken(_life):
	print(_life)
	if _life <= hp_threshold:
		STGGlobal.end_sequence.emit()
