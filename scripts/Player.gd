extends CharacterBody2D
const SPEED = 400
var direction:Vector2


func _ready():
	pass


func _physics_process(_delta):
	
	direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	
	if Input.is_action_pressed("focus"):
		direction*=0.45
		$Hitbox.show()
	else:
		$Hitbox.hide()
	set_velocity(direction*SPEED)
	move_and_slide()

func _on_Hitbox_area_entered(_area):
	position = Vector2.ZERO

