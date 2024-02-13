extends Label

func _ready():
	STGGlobal.spell_changed.connect(Callable(self, "_on_spell_changed"))

func _on_spell_changed(data:STGCustomData):
	if data.name.is_empty():
		text = ""
	else:
		spell_name_animation(data.name)

func spell_name_animation(spell_name:String):
	modulate.a = 0
	position.y = 417
	text = spell_name
	var tw := create_tween()
	tw.tween_property(self, "modulate", Color.WHITE, 0.2)
	await tw.finished
	tw = create_tween()
	tw.tween_property(self, "position", Vector2(position.x, -47), 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
