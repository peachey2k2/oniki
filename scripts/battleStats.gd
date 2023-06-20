extends Node

#bar_count:int - the amount of health bars
#spell count:int - how many spells that phase/bar has

#name:string - name of the spell, displayed at the top of the screen
#health:int - how many hits it takes to capture that spell, displayed at top left
#time:int - the initial value of the timeout timer, displayed at top right

#offset:Vector2 - the point where all the bullets will spawn relative to the origin node
#amount:int - amount of bullets per circle
#repeat:int - how many circles the function will create before stopping
#tilt:float - how much the circle should tilt every time
#velocity:Vector2 - vector to control the speed. it'll be rotated for every generated bullet. 
#distance:float - how far from the origin bullets will spawn in
#delay:float - time delay between each circle

var enemy = {
	"bar_count": 1,
	0: {
		"spell_count": 1,
		0: {
			"name": "placeholder",
			"health": 20,
			"time": 50,
			"amount": 5,
			"repeat": 10000,
			"tilt": PI/17,
			"velocity": Vector2(200, 0),
			"distance": 50,
			"delay": 0.15
		}
	}
}
