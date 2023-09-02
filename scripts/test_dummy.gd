extends Area2D

func on_interact():
	GFS.play_dialogue(str(get_meta("dialogue_id")))
	
	#GFS.initiate_battle(self)
