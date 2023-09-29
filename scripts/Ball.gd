extends Area2D

const GRAVITY = Vector2(0, 3000)
const H_SPEED_CAP = 1000
const V_SPEED_CAP = 1500
const H_SPEED_MIN = 400

@onready var LifeBar = GFS.CurrentArena.get_node("BattleUI/LifeBarContainer")

var velocity = Vector2(300, 0)
var last_pos

func _ready():
	GFS.Player.shoot.connect(Callable(self, "_on_player_shoot"))

func _physics_process(delta):
	last_pos = position
	velocity += GRAVITY * delta
	if velocity.x > 0:
		velocity.x = clamp(velocity.x, H_SPEED_MIN, H_SPEED_CAP)
	else:
		velocity.x = clamp(velocity.x, -H_SPEED_CAP, -H_SPEED_MIN)
	velocity.y = clamp(velocity.y, -V_SPEED_CAP, V_SPEED_CAP)
	position += velocity * delta

func _on_player_shoot():
	if !has_overlapping_areas(): return
	var angle = GFS.get_angle_as_vector(self, GFS.Enemy)
	trail(position, GFS.Enemy.position)
	position = GFS.Enemy.position
	velocity.x = angle.x * 1000
	velocity.y = -1000
	LifeBar.damage()

func trail(start, end):
	var Laser = Laser2D.new()
	Laser.width = 60
	Laser.add_point(start)
	Laser.add_point(end)
	Laser.color_outer = Color.TRANSPARENT
	GFS.ArenaViewport.add_child(Laser)
	var tween = create_tween()
	tween.tween_property(Laser, "modulate", Color.TRANSPARENT, 0.5)
	await tween.finished
	Laser.queue_free()
