extends Node2D
@onready var Bullet = preload("res://scenes/Bullet.tscn")
@onready var BattleStats = get_node("/root/BattleStats")

func spawn_bullet(velocity, distance, delta):
	var Bullet_ins = Bullet.instantiate()
	Bullet_ins.position = velocity.normalized()*distance
	Bullet_ins.velocity = velocity
	add_child(Bullet_ins)

func arrange_bullets_circular(
amount:int, # amount of bullets per circle
repeat:int, # how many circles the function will create before stopping
tilt:float, # how much the circle should tilt every time
velocity:Vector2, # vector to control the speed. it'll be rotated for every generated bullet. 
distance:float, #how far from the origin bullets will spawn in
delay:float, # time delay between each circle
delta):	
	var gap = PI*2/amount
	for j in repeat:
		for k in amount:
			spawn_bullet(velocity, distance, delta)
			velocity = Vector2(
				velocity.length()*cos(velocity.angle()+gap),
				velocity.length()*sin(velocity.angle()+gap)
				)
		await get_tree().create_timer(delay).timeout
		velocity = Vector2(
			velocity.length()*cos(velocity.angle()+tilt),
			velocity.length()*sin(velocity.angle()+tilt)
			)



