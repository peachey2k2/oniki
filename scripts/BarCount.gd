extends Label

func _ready():
	STGGlobal.bar_changed.connect(Callable(self, "_on_bar_changed"))

func _on_bar_changed(val, _datas):
	text = str(val)
