@tool
extends Node2D

const PRE_SPELL_WAIT_TIME = 1

signal battle_start
signal shield_changed(value:int)
signal spell_name_changed(value:String)
signal end_spell
signal end_battle

@export_category("BattleController")
@export var stats:STGStats
@export var bullets:Array[STGPackedBulletContainer]

var bar_count:int
var life:int
var shield_state:int
var _arena_rect:Rect2
var _spawner_container:Node2D
var pools:Array[Array]

func lerp4arena(weight:Vector2) -> Vector2:
	return Vector2(
		lerp(_arena_rect.position.x, _arena_rect.end.x, weight.x),
		lerp(_arena_rect.position.y, _arena_rect.end.y, weight.y)
	)

func battle(spawner_container:Node2D, player:Node2D, enemy:Node2D, arena_rect:Rect2):
	STGGlobal.controller = self
	pools.resize(bullets.size())
	for i in bullets.size():
		var bullet_data = bullets[i]
		var bullet = bullet_constructor(bullet_data)
		bullet_pool(bullet, bullet_data.pool_size, i)
	battle_start.emit()
	_spawner_container = spawner_container
	_arena_rect = arena_rect
	bar_count = stats.bars.size()
	life = 0
	shield_state = 0
	player.position = lerp4arena(stats.player_position)
#	BattleUI.get_node("Graze").reset()
	for curr_bar in stats.bars:
		for curr_spell in curr_bar.spells:
			enemy.position = lerp4arena(curr_spell.enemy_pos)
			change_shield(curr_spell.shield)
#			LifeBar.fill_health(spell.get("health"))
			spell_timer(curr_spell.time)
			spell_name_changed.emit(curr_spell.name)
			await get_tree().create_timer(PRE_SPELL_WAIT_TIME, false).timeout
			enemy.monitoring = true
			for curr_sequence in curr_spell.sequences:
				#AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
				for curr_spawner in curr_sequence.spawners:
					var spawner = STGSpawnerNode.new()
					spawner.pool = pools[curr_spawner.bullet_index]
					spawner_container.add_child(spawner)
					match curr_spawner.position_type:
						0: spawner.position = lerp4arena(curr_spawner.position)
						1: spawner.position = lerp4arena(curr_spawner.position) + enemy.position
					spawner.rotation_speed = curr_spawner.rotation_speed
					curr_spawner.spawn(spawner)
			await end_spell
			enemy.monitoring = false
	end_battle.emit()


func bullet_constructor(data:STGPackedBulletContainer) -> STGBullet:
	var bullet = STGBullet.new()
	bullet.sprite_outer = Sprite2D.new()
	bullet.sprite_inner = Sprite2D.new()
	bullet.collision = CollisionShape2D.new()
	bullet.collision.shape = data.collision
	bullet.add_child(bullet.sprite_outer)
	bullet.add_child(bullet.sprite_inner)
	bullet.add_child(bullet.collision)
	bullet.sprite_inner.z_index = 1
	bullet.collision.z_index = 2
	bullet.collision_layer = 2
	bullet.sprite_outer.texture = data.outer_texture
	bullet.sprite_inner.texture = data.inner_texture
	bullet.sprite_outer.modulate = data.outer_color
	bullet.sprite_inner.modulate = data.inner_color
	bullet.sprite_outer.scale = data.outer_scale * Vector2(1, 1)
	bullet.sprite_inner.scale = data.inner_scale * Vector2(1, 1)
	return bullet

func bullet_pool(bullet:STGBullet, size:int, i:int):
	bullet.index = i
	var pool = pools[i]
	pool.append(bullet)
	for j in size-1:
		pool.append(bullet.duplicate())

func change_shield(shield:int):
	shield_state = shield
	shield_changed.emit(shield)

func spell_timer(time:float):
	var timer:SceneTreeTimer = get_tree().create_timer(time, false)
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	return timer

func _on_timer_timeout():
	pass

func _on_bar_emptied():
	for i in _spawner_container.get_children():
		i.queue_free()
	end_spell.emit()

func _on_spell_timed_out():
	for i in _spawner_container.get_children():
		i.queue_free()
	end_spell.emit()
