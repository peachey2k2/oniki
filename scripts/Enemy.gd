extends Area2D

var id:String
var Shield:Node

func _ready():
	Shield = $Shield
	STGGlobal.shield_changed.connect(Callable(self, "_on_shield_changed"))

func _on_shield_changed(shield:int):
	match shield:
		0: Shield.modulate = Color.TRANSPARENT
		1: Shield.modulate = Color.RED
