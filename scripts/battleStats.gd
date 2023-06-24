extends Node

enum {CIRCULAR}
enum {SMALL, MEDIUM, LARGE, XLARGE}

#bar_count:int - the amount of health bars
#spell count:int - how many spells that phase/bar has

#name:string - name of the spell, displayed at the top of the screen
#health:int - how many hits it takes to capture that spell, displayed at top left
#time:int - the initial value of the timeout timer, displayed at top right
#spawner_count:int - amount of spawner objects to use

var enemy = {
	"bar_count": 1,
	0: {
		"spell_count": 1,
		0: {
			"name": "placeholder",
			"health": 5,
			"time": 50,
			"spawner_count": 1,
			0: {
				"offset": Vector2(0, 0),
				"type": CIRCULAR,
				"bullet_type": MEDIUM,
				"bullet_color": Color.RED,
				"amount": 5,
				"repeat": 10000,
				"tilt": PI/17,
				"velocity": Vector2(200, 0),
				"distance": 50,
				"delay": 0.15
			}
		}
	}
}
