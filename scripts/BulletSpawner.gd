extends Node2D
@onready var Small:PackedScene = preload("res://scenes/bullets/small.tscn")
@onready var Medium:PackedScene = preload("res://scenes/bullets/medium.tscn")
@onready var Large:PackedScene = preload("res://scenes/bullets/large.tscn")
@onready var XLarge:PackedScene = preload("res://scenes/bullets/xlarge.tscn")
@onready var BattleStats = get_node("/root/BattleStats")

func spawn_bullet(velocity, distance, color, type):
	var Bullet_ins = type.instantiate()
	Bullet_ins.position = velocity.normalized()*distance
	Bullet_ins.velocity = velocity
	Bullet_ins.get_node("outer").modulate = color
	add_child(Bullet_ins)

func arrange_bullets_circular(
bullet_type:int,		# the type of the bullet
bullet_color:Color,		# the color of the bullet
amount:int, 			# amount of bullets per circle
repeat:int, 			# how many circles the function will create before stopping
tilt:float, 			# how much the circle should tilt every time
velocity:Vector2, 		# vector to control the speed. it'll be rotated for every generated bullet. 
distance:float, 		# how far from the origin bullets will spawn in
delay:float, 			# time delay between each circle
):	
	var gap = PI*2/amount
	var type:PackedScene
	match bullet_type:
		0: type = Small
		1: type = Medium
		2: type = Large
		3: type = XLarge
	for i in repeat:
		for j in amount:
			var angle = velocity.angle()
			spawn_bullet(velocity, distance, bullet_color, type)
			velocity = Vector2(
				velocity.length()*cos(angle+gap),
				velocity.length()*sin(angle+gap)
				)
		await get_tree().create_timer(delay).timeout
		var angle = velocity.angle()
		velocity = Vector2(
			velocity.length()*cos(angle+tilt),
			velocity.length()*sin(angle+tilt)
			)



