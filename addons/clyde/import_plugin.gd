@tool
extends EditorImportPlugin

const Parser = preload("./parser/Parser.gd")

func _get_priority():
	return 1

func _get_import_order():
	return 1

func _get_importer_name():
	return "clyde.dialogue"


func _get_visible_name():
	return "Clyde Dialogue Importer"


func _get_recognized_extensions():
	return ["clyde"]


func _get_save_extension():
	return "res"


func _get_resource_type():
	return "PackedDataContainer"


func _get_preset_count():
	return 1


func _get_preset_name(i):
	return "Default"


func _get_import_options(_path, _i):
	return []


func _get_option_visibility(_path, _option, _options):
	return true


func _import(source_file, save_path, options, platform_variants, gen_files):
	var file = FileAccess.open(source_file, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()
	var clyde = file.get_as_text()
	var result = parse(clyde)
	file.close()

	var container = PackedDataContainer.new()
	container.__data__ = JSON.stringify(result).to_utf8_buffer()

	return ResourceSaver.save(container, "%s.%s" % [save_path, _get_save_extension()])


func parse(input):
	var parser = Parser.new()
	return parser.parse(input)
