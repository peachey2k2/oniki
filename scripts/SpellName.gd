extends Label

func _ready():
	STGGlobal.spell_changed.connect(Callable(self, "_on_spell_changed"))

func _on_spell_changed(data:STGCustomData):
	if data.name.is_empty():
		text = ""
	else:
		text = data.name
