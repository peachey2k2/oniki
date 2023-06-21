extends HBoxContainer
@onready var portion = preload("res://scenes/life_bar_portion.tscn")
var maxLife = 0
var currLife = 0
var playerInRange := false
var hitOnCooldown := false
signal bar_emptied

const HIT_COOLDOWN = 1

func _ready():
	$"../../Enemy".connect("area_entered",Callable(self,"_on_area_entered"))
	$"../../Enemy".connect("area_exited",Callable(self,"_on_area_exited"))

func _on_area_entered(area):
	playerInRange = true

func _on_area_exited(area):
	playerInRange = false

func _physics_process(delta):
	if Input.is_action_pressed("hit") && !hitOnCooldown:
		hitOnCooldown = true
		if currLife != 0 && playerInRange: #Z
			currLife -= 1
			get_child(currLife).color = Color(0, 0, 0, 0)
			if currLife == 0:
				emit_signal("bar_emptied")
				fillHealth(currLife)
		await get_tree().create_timer(HIT_COOLDOWN).timeout
		hitOnCooldown = false

func fillHealth(lifeInput):
	clearHealth()
	maxLife = lifeInput
	currLife = lifeInput
	for i in range(lifeInput):
		var portion_ins = portion.instantiate()
		add_child(portion_ins)

func clearHealth():
	for i in maxLife:
		get_child(i).queue_free()

