@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("ParallaxButGood", "TextureRect", preload("res://addons/deranged_additions/nodes/parallax_but_good.gd"), preload("res://icon.png"))
	pass


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_custom_type("ParallaxButGood")
