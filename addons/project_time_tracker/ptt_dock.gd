@tool
extends Control

@export var lbl_CST: RichTextLabel
@export var lbl_LST: RichTextLabel
@export var lbl_TOOD: RichTextLabel
@export var cb_sn: CheckBox
@export var lbl_StartDate: Label

const TICK_TIME: float = 1

var elapsed_time: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if !PTTUtils.ptt.has_data():
		printerr("Couldn't launch Project Time Tracker. Data file empty!")
		return
	
	set_process(PTTUtils.ptt.has_data())
	
	cb_sn.set_pressed_no_signal(PTTUtils.ptt.time_short_notation)
	
	var str_lst := PTTUtils.bb_text("Last Session", PTTUtils.ptt.get_data(PTTUtils.LS), true)
	lbl_LST.text = str_lst

func _process(delta):
	elapsed_time += delta
	if (elapsed_time > TICK_TIME):
		elapsed_time = 0
		PTTUtils.ptt.increment(PTTUtils.ST)
		PTTUtils.ptt.increment(PTTUtils.TT)
		
		update_ui()

func update_ui():
	var str_cst := PTTUtils.bb_text("Current Session", PTTUtils.ptt.get_data(PTTUtils.ST))
	lbl_CST.text = str_cst
	
	var tracked_total_time: int = PTTUtils.ptt.get_data(PTTUtils.TT)
	var dhms: String = PTTUtils.secondsToDhms(tracked_total_time, PTTUtils.ptt.time_short_notation)
	var total_on_off_days: int = PTTUtils.ptt.get_data(PTTUtils.TD)
	var YMd: String = PTTUtils.daysToYMD(total_on_off_days)
	var str_days := "Over [color=gold]%s[/color]" % [YMd]
	
	var str_tood := "Combined Time %s\n[color=white]%s[/color]" % [str_days, dhms]
	lbl_TOOD.text = str_tood
	
	var tracking_start_date: String = Time.get_datetime_string_from_unix_time(PTTUtils.ptt._data[PTTUtils.SD], true)
	lbl_StartDate.text = "Tracking Started:\n%s" % [tracking_start_date]

func _on_check_box_toggled(toggled_on):
	PTTUtils.ptt.time_short_notation = toggled_on
	PTTUtils.ptt.set_data(PTTUtils.SN, PTTUtils.ptt.time_short_notation)
	
	update_ui()

func _notification(what): 
	match what:
		NOTIFICATION_EDITOR_POST_SAVE:
			PTTUtils.ptt.update_last_session_to_current()
			PTTUtils.save_data()

func _exit_tree():
	PTTUtils.ptt.update_last_session_to_current()
	PTTUtils.ptt.set_data(PTTUtils.ST, 0)
	PTTUtils.save_data()
