extends Node

enum {GENERIC, PLAYER}
enum {STATIC, RANDOM}
enum {CIRCULAR, LINEAR}
enum {ABSOLUTE, RELATIVE}
enum {SMALL, MEDIUM, LARGE, XLARGE}
enum {OFF, ON}

func get_stats(id:String) -> Dictionary:
	return get(id)

#bar_count:int - the amount of health bars
#spell count:int - how many spells that phase/bar has

#name:string - name of the spell, displayed at the top of the screen
#health:int - how many hits it takes to capture that spell, displayed at top left
#time:int - the initial value of the timeout timer, displayed at top right
#spawner_count:int - amount of spawner objects to use

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
					"position": Vector2(0, 0),
					"pos_type": ABSOLUTE,
					"speed": 0,
					"towards": GENERIC,
					"rotation_speed": 0,
				},
				"bullet":{
					"bullet_type": MEDIUM,
					"bullet_color": Color.RED,
					"init_angle": 0,
					"amount": 16,
					"repeat": 1000,
					"speed": 100,
					"start_point": Vector2(0, 0),
					"gap": Vector2(0.07, 0),
					"delay": 0.5,
					"sleep": 0,
					"bullet_angle": PI/2,
					"bullet_skew": 1,
					"towards": GENERIC,
					"acceleration": 0,
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
