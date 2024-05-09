@tool
class_name PTTUtils

const PTT_FILE_NAME = "res://ptt.json"

const SD := "sd"    # Tracking Start Date
const ST := "st"    # Current Session Time
const LS := "ls"    # Last Session Time
const TT := "tt"    # Tracking Total Time
const TD := "td"    # Total On/Off Days
const LO := "lo"    # Last Opened Date
const SN := "sn"    # Short Notation Setting

const defaults = { ST: 0, LS: 0, TT: 0, TD: 0, SD: 0, LO: "", SN: false }

static var ptt: PTT = PTT.new()

static func load_data() -> Dictionary:
	if not FileAccess.file_exists(PTT_FILE_NAME):
		save_data(defaults)
	var file = FileAccess.open(PTT_FILE_NAME, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	if data is Dictionary:
		for key in defaults:
			if key not in data:
				data[key] = defaults[key]
		file.close()
		return data
	else:
		file.close()
		printerr("Error loading %s file" % [PTT_FILE_NAME])
		return {}

static func save_data(data = ptt._data):
	var file = FileAccess.open(PTT_FILE_NAME, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

static func get_date(unix_time: int) -> String:
	return Time.get_date_string_from_unix_time(unix_time)

static func time_format(time: int) -> String:
	var seconds: float = time % 60
	var minutes: float = (time / 60) % 60
	var hours: float = (time / 60) / 60
	
	var str_h := ""
	if hours > 0:
		str_h = "%02d:" % [hours]
	
	var str_m := ""
	if minutes > 0:
		str_m = "%02d:" % [minutes]
	
	var str_s := "%02d" % [seconds]
	
	var str: String = str_h + str_m + str_s
	
	return str

static func secondsToDhms(seconds: int, short_notation: bool = false) -> String:
	var d: float = seconds / (3600 * 24)
	var h: float = fmod(seconds, 3600 * 24) / 3600
	var m: float = fmod(seconds, 3600) / 60
	var s: float = fmod(seconds, 60)
	
	var dDisplay: String = check_plural("day", d, short_notation)
	var hDisplay: String = check_plural("hour", h, short_notation)
	var mDisplay: String = check_plural("minute", m, short_notation)
	var sDisplay: String = check_plural("second", s, short_notation)
	
	var display: String = dDisplay + hDisplay + mDisplay + sDisplay
	display = display.left(-2)
	return "~ " + display

static func daysToYMD(days: int, short_notation: bool = false) -> String:
	var Y: float = days / 365
	var M: float = (days % 365) / 30.4167
	var d: float = fmod((days % 365), 30.4167)
	
	var YDisplay: String = check_plural("Year", Y, short_notation)
	var MDisplay: String = check_plural("Month", M, short_notation)
	var dDisplay: String = check_plural("Day", d, short_notation)
	
	var display: String = YDisplay + MDisplay + dDisplay
	display = display.left(-2)
	return display
	
static func check_plural(str: String, num: int, short: bool = false) -> String:
	var display := ""
	if num > 0:
		var result: String = str if (num == 1) else (str + "s")
		display = "%d%s, " % [num, result[0]] if short else "%d %s, " % [num, result]
	return display

static func color_temp(session_time: int) -> String:
	var str_color := "green"
	
	if (session_time > 14400):
		str_color = "red"
	elif (session_time > 10800):
		str_color = "coral"
	elif (session_time > 7200):
		str_color = "yellow"
	elif (session_time > 3600):
		str_color = "green_yellow"
		
	return str_color

static func bb_text(title: String, time: float, dhms: bool = false) -> String:
	var _time_format: String = time_format(time)
	if (dhms):
		_time_format = secondsToDhms(time, true)
	var _bb_color: String = color_temp(time)
	var _str := "[center]%s\n[color=%s]%s[/color][/center]" % [title, _bb_color, _time_format]
	return _str


# #######################
# Accessibility Functions
# #######################

# returns the date timestamp of when tracking started.
static func tracking_start_time() -> int:
	return ptt._data[PTTUtils.SD]

# returns the total (combined sessions) time integer.
static func total_active_time() -> int:
	return ptt._data[PTTUtils.TT]
	
# returns the total active time in readable string format, suffix defaults to "elapsed" -> "6 hours 2 minutes elapsed"
static func total_active_time_string(suffix: String = "elapsed") -> String:
	var dhms: String = PTTUtils.secondsToDhms(total_active_time(), true)
	return dhms + " " + suffix

# returns the integer of total days of work on the project.
static func total_period() -> int:
	return ptt._data[PTTUtils.TD]

# returns the total days of work on the project in readable string format, suffix defaults to "elapsed" -> "1 month 3 days... elapsed"
static func total_period_string(suffix: String = "elapsed") -> String:
	var YMd: String = PTTUtils.daysToYMD(total_period())
	return YMd + " " + suffix
