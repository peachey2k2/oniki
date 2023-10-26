class_name CircularSpawner extends STGSpawner

@export_group("Pattern")
@export var init_angle:float:
	set(val):
		init_angle_rad = deg_to_rad(val)
		init_angle = val
## amount of bullets per circle
@export var amount:int = 5
## how many circles the function will create before stopping
@export var repeat:int = 5
## how much the circle should tilt every time
@export var tilt:float:
	set(val):
		tilt_rad = deg_to_rad(val)
		tilt = val
## how far from the origin bullets will spawn in
@export var distance:float
## how much the pattern will be stretched/squished
@export var stretch:float = 1
## time delay between each spawn cycle (in seconds)
@export var delay:float = 0.1
## the wait time after every bullet

var init_angle_rad:float
var tilt_rad:float

func _spawn():
	var gap = PI*2/amount
	var velocity = bullet.speed * Vector2.from_angle(init_angle_rad)
	for i in repeat:
		for j in amount:
			var velocity_normalized = velocity.normalized()
			if stop_flag: return
			spawn_bullet(
				real_pos + velocity_normalized * distance,
				Vector2(velocity.x, velocity.y * stretch),
				velocity_normalized * bullet.acceleration
			)
			velocity = velocity.rotated(gap)
		velocity = velocity.rotated(tilt_rad)
		await STGGlobal.get_tree().create_timer(delay, false).timeout
