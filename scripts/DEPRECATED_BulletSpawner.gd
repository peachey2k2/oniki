extends Node2D
@onready var Small:PackedScene = preload("res://scenes/bullets/small.tscn")
@onready var Medium:PackedScene = preload("res://scenes/bullets/medium.tscn")
@onready var Large:PackedScene = preload("res://scenes/bullets/large.tscn")
@onready var XLarge:PackedScene = preload("res://scenes/bullets/xlarge.tscn")
@onready var BattleStats = $"/root/BattleStats"

var rotation_speed:float

func _process(delta):
	rotation += rotation_speed * delta

func bullet_generic(velocity, bullet_pos, color, type, acceleration, angle, sine_freq, sine_width):
#	var Bullet_ins = type.instantiate()
	var Bullet_ins = STGGlobal.get_bullet()
	Bullet_ins.position = bullet_pos
	Bullet_ins.acceleration = acceleration * angle
	Bullet_ins.velocity = velocity.length() * angle
	Bullet_ins.sine_freq = sine_freq
	Bullet_ins.sine_width = sine_width
	Bullet_ins.called()
#	Bullet_ins.get_child(0).modulate = color
	add_child(Bullet_ins)
	
func bullet_on_player(velocity, bullet_pos, color, type, acceleration, angle, sine_freq, sine_width):
	var Bullet_ins = type.instantiate()
	Bullet_ins.position = bullet_pos
	Bullet_ins.acceleration = acceleration * angle
	Bullet_ins.sine_freq = sine_freq
	Bullet_ins.sine_width = sine_width
	Bullet_ins.get_node("outer").modulate = color
	add_child(Bullet_ins)
	Bullet_ins.velocity = velocity.length() * GFS.get_angle_as_vector(Bullet_ins, GFS.Player)
	#last line has to be after add_child() cuz otherwise global_transform.origin is 0.

func _get_bullet_type(type:int):
	match type:
		0: return Small
		1: return Medium
		2: return Large
		3: return XLarge

func circular(
	bullet_type_id:int,		# the type of the bullet
	bullet_color:Color,		# the color of the bullet
	init_angle:float,		#
	amount:int, 			# amount of bullets per circle
	repeat:int, 			# how many circles the function will create before stopping
	tilt:float, 			# how much the circle should tilt every time
	speed:float, 			# vector to control the speed. it'll be rotated for every generated bullet. 
	distance:float, 		# how far from the origin bullets will spawn in
	stretch:float,			# how much the pattern will be stretched/squished
	delay:float, 			# time delay between each spawn cycle (in seconds)
	sleep:float,			# the wait time after every bullet
	towards:int,			#
	acceleration:float,		#
	sine_freq:float,		#
	sine_width:float,		#
):
	rotation = init_angle
	var gap = PI*2/amount
	var velocity = Vector2(speed, 0)
	var type:PackedScene = _get_bullet_type(bullet_type_id)
	for i in repeat:
		for j in amount:
			var angle = velocity.angle()
			var angle_vector = velocity.normalized()
			match towards:
				0: bullet_generic(Vector2(velocity.x, velocity.y * stretch), velocity.normalized()*distance, bullet_color, type, acceleration, angle_vector, sine_freq, sine_width)
				1: bullet_on_player(Vector2(velocity.x, velocity.y * stretch), velocity.normalized()*distance, bullet_color, type, acceleration, angle_vector, sine_freq, sine_width)
			await get_tree().create_timer(sleep, false).timeout
			velocity = Vector2(
				velocity.length()*cos(angle+gap),
				velocity.length()*sin(angle+gap)
				)
		await get_tree().create_timer(delay, false).timeout
		var angle = velocity.angle()
		velocity = Vector2(
			velocity.length()*cos(angle+tilt),
			velocity.length()*sin(angle+tilt)
			)
			
func _skew(skew_mul):
	return skew_mul * (GFS.Rng.randf() - 0.5)

func linear(
	bullet_type_id:int,		# the type of the bullet
	bullet_color:Color,		# the color of the bullet
	init_angle:float,		#
	amount:int, 			# amount of bullets per line
	repeat:int, 			# how many lines the function will create before stopping
	speed:float, 			# vector to control the speed. it'll be rotated for every generated bullet. 
	start_point:Vector2, 	# the starting point of the line
	is_random:bool,			#
	gap:Vector2,			# gap between each bullet in the line
	delay:float, 			# time delay between each spawn cycle (in seconds)
	sleep:float,			# the wait time after every bullet
	bullet_angle:float,		#
	skew_mul:float,			# how much the bullet can diverge from its path
	towards:int,			#
	acceleration:float,		#
	sine_freq:float,		#
	sine_width:float,		#
):
	rotation = init_angle
	var velocity = Vector2(speed, 0)
	var type:PackedScene = _get_bullet_type(bullet_type_id)
	if is_random:
		var end_point = start_point + gap
		for i in repeat:
			for j in amount:
				var last_pos = lerp(start_point, end_point, GFS.Rng.randf())
				match towards:
					0: bullet_generic(velocity + 5*Vector2(_skew(skew_mul), _skew(skew_mul)), last_pos, bullet_color, type, acceleration, Vector2.RIGHT.rotated(bullet_angle + _skew(skew_mul)), sine_freq, sine_width)
					1: bullet_on_player(velocity + 5*Vector2(_skew(skew_mul), _skew(skew_mul)), last_pos, bullet_color, type, acceleration, Vector2.RIGHT.rotated(bullet_angle + _skew(skew_mul)), sine_freq, sine_width)
				await get_tree().create_timer(sleep, false).timeout
			await get_tree().create_timer(delay, false).timeout
	else:
		for i in repeat:
			var last_pos:Vector2 = start_point
			for j in amount:
				match towards:
					0: bullet_generic(velocity + 5*Vector2(_skew(skew_mul), _skew(skew_mul)), last_pos, bullet_color, type, acceleration, Vector2.RIGHT.rotated(bullet_angle + _skew(skew_mul)), sine_freq, sine_width)
					1: bullet_on_player(velocity + 5*Vector2(_skew(skew_mul), _skew(skew_mul)), last_pos, bullet_color, type, acceleration, Vector2.RIGHT.rotated(bullet_angle + _skew(skew_mul)), sine_freq, sine_width)
				await get_tree().create_timer(sleep, false).timeout
				last_pos += gap
			await get_tree().create_timer(delay, false).timeout
	


