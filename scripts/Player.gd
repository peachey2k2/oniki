extends CharacterBody2D
const SPEED = 400
var direction:Vector2
#var window_size = Window.get_size()


func _ready():
	pass # Replace with function body.


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

