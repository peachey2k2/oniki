@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("BattleController", "Node2D", preload("res://addons/GodotSTG/battle_controller.gd"), preload("res://icon.png"))
	add_autoload_singleton("STGGlobal", "res://addons/GodotSTG/STGPool.gd")

func _exit_tree():
	remove_custom_type("BattleController")
	remove_autoload_singleton("STGGlobal")
