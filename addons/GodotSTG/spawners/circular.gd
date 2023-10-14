@tool
class_name CircularSpawner extends STGSpawner

@export_group("Pattern")
@export var init_angle:float
## amount of bullets per circle
@export var amount:int
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
@export var delay:float
## the wait time after every bullet

var rotation = init_angle
var tilt_rad:float

func spawn(container:Node2D):
	var tree = container.get_tree()
	var gap = PI*2/amount
	var velocity = bullet.speed * Vector2.from_angle(init_angle)
	for i in repeat:
		for j in amount:
			var velocity_normalized = velocity.normalized()
			if container == null: return
			container.spawn_bullet.call(velocity_normalized * distance, Vector2(velocity.x, velocity.y * stretch), velocity_normalized * bullet.acceleration)
			velocity = velocity.rotated(gap)
		velocity = velocity.rotated(tilt_rad)
		await tree.create_timer(delay, false).timeout
