extends Node

enum {GENERIC, PLAYER}
enum {STATIC, RANDOM}
enum {CIRCULAR, LINEAR}
enum {ABSOLUTE, RELATIVE}
enum {SMALL, MEDIUM, LARGE, XLARGE}
enum {OFF, ON}

func get_stats(id:String) -> Dictionary:
	return get(id)

var test_dummy = {
	"player_pos": Vector2(0.5, 0.8),
	"bar_count": 2,
	0: {
		"spell_count": 1,
		0: {
			"name": "test",
			"health": 1,
			"time": 30,
			"spawner_count": 1,
			"enemy_pos": Vector2(0.5, 0.5),
			"enemy_movement": STATIC,
			"shield": ON,
			0:{
				"spawner" :{
					"type": LINEAR,
					"position": Vector2(0, -0.1),
					"pos_type": ABSOLUTE,
					"speed": 0,
					"towards": GENERIC,
					"rotation_speed": 0,
				},
				"bullet":{
					"bullet_type": MEDIUM,
					"bullet_color": Color.RED,
					"init_angle": 0,
					"amount": 1,
					"repeat": 100000,
					"speed": 120,
					"start_point": Vector2(0, 0),
					"is_random": true,
					"gap": Vector2(1, 0),
					"delay": 0.02,
					"sleep": 0,
					"bullet_angle": PI/2,
					"bullet_skew": 1,
					"towards": GENERIC,
					"acceleration": 50,
					"sine_freq": 0,
					"sine_width": 0,
				}
			}
		}
	},
	1:{
		"spell_count": 1,
		0: {
			"name": "placeholder",
			"health": 10,
			"time": 30,
			"spawner_count": 2,
			"enemy_pos": Vector2(0.5, 0.5),
			"enemy_movement": STATIC,
			"shield": OFF,
			0: {
				"spawner" :{
					"type": CIRCULAR,
					"position": Vector2(0, 0),
					"pos_type": RELATIVE,
					"speed": 0,
					"towards": GENERIC,
					"rotation_speed": 0.4
				},
				"bullet" :{
					"bullet_type": MEDIUM,
					"bullet_color": Color.RED,
					"init_angle": 0,
					"amount": 6,
					"repeat": 10000,
					"tilt": 0,
					"speed": 150,
					"distance": 0,
					"stretch": 1,
					"delay": 0.25,
					"sleep": 0,
					"towards": GENERIC,
					"acceleration": 0,
					"sine_freq": 1,
					"sine_width": 500
				}
			},
			1: {
				"spawner" :{
					"type": CIRCULAR,
					"position": Vector2(0, 0),
					"pos_type": RELATIVE,
					"speed": 0,
					"towards": GENERIC,
					"rotation_speed": 0
				},
				"bullet" :{
					"bullet_type": MEDIUM,
					"bullet_color": Color.BLUE,
					"init_angle": 0,
					"amount": 9,
					"repeat": 10000,
					"tilt": 0.1,
					"speed": 100,
					"distance": 50,
					"stretch": 1,
					"delay": 0.4,
					"sleep": 0,
					"towards": GENERIC,
					"acceleration": 0,
					"sine_freq": 0,
					"sine_width": 0
				}
			}
		}
	}
}
