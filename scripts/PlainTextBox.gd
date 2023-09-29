extends Label

var velocity = Vector2(0, -7)
const ACCELERATION = Vector2(0, 0.6)

func _ready():
	position = -size / 2 + Vector2(0, 550)

func _physics_process(_delta):
	velocity += ACCELERATION
	position += velocity
	if velocity.y > 7:
		queue_free()
