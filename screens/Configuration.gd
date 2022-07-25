extends "AbstractScreen.gd"

const TextManager = preload("res://scripts/text_manager.gd")
const GoogleLocales = preload("res://scripts/locales.gd")

onready var _language_option_button = $MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/LanguageOptionButton
onready var _google_translate_button = $MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/HBoxContainer/GoogleTranslateButton
onready var _manual_translate_button = $MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/HBoxContainer/ManualTranslateButton
onready var _always_on_top_button = $AlwaysOnTopButton
onready var _file_dialog = $FileDialog
onready var _accept_dialog = $AcceptDialog
onready var _config = get_node("/root/Config")
onready var _data = get_node("/root/LocalizationData")

func _ready():
	_always_on_top_button.set_pressed(_config.get_window_always_on_top())
	setup_language_option_button()
	get_tree().connect("files_dropped", self, "_on_files_dropped")
	_parse_cmdline()

func _parse_cmdline():
	for argument in OS.get_cmdline_args():
		_on_FileDialog_file_selected(argument)
		break

func _process(_delta):
	_language_option_button.disabled = _data.text_directory.empty()
	_google_translate_button.disabled = _data.language_directory.empty()
	_manual_translate_button.disabled = _data.language_directory.empty()

func _on_SelectGameButton_pressed():
	_file_dialog.popup_centered()
	_file_dialog.set_current_path(_config.get_game_path())

func _on_files_dropped(files: PoolStringArray, screen: int) -> void:
	_file_dialog.visible = false
	_on_FileDialog_file_selected(files[0])

func _on_FileDialog_file_selected(path: String):
	var dir = Directory.new()
	var text_dir = path.get_base_dir() + "/Text"
	
	if not dir.dir_exists(text_dir):
		_accept_dialog.dialog_text =  "Directory " + text_dir + " does not exist!"
		_accept_dialog.popup_centered()
		return
	
	_data.text_directory = text_dir
	_data.game_directory = path.get_base_dir()
	
	_config.set_game_path(path)
	copy_file(_data.get_image_source(), _data.get_image_target())

func _on_LanguageOptionButton_item_selected(index):
	_data.language = _language_option_button.get_item_metadata(index)
	
	match _data.get_language():
		"en":
			_data.language_directory = "ENG"
		"es":
			_data.language_directory = "ESP"
		"ko":
			_data.language_directory = "KOR"
		"ru":
			_data.language_directory = "RUS"
		_:
			_data.language_directory = "CHT"
	
	copy_recursive(_data.get_source_dir(), _data.get_target_dir())

func _on_GoogleTranslateButton_pressed():
	emit_signal("next_screen", "google_translate")

func _on_ManualTranslateButton_pressed():
	emit_signal("next_screen", "manual_translate")

func _on_AlwaysOnTopButton_toggled(button_pressed):
	_config.set_window_always_on_top(button_pressed)
	OS.set_window_always_on_top(button_pressed)

func setup_language_option_button():
	_language_option_button.add_item(_language_option_button.text, 0)
	_language_option_button.set_item_disabled(0, true)
	
	var index = 1
	for item in GoogleLocales.LOCALES:
		_language_option_button.add_item(item["name"], index)
		_language_option_button.set_item_metadata(index, item["code"])
		index = index + 1

func copy_recursive(from: String, to: String) -> void:
	var directory := Directory.new()
	
	if not directory.dir_exists(to):
		if directory.make_dir_recursive(to) != OK:
			printerr("Failed to create directory %s" % to)
			return
	
	if directory.open(from) != OK:
		printerr("Unable to open directory %s" % from)
		return
	
	if directory.list_dir_begin(true) != OK:
		printerr("Unable to list directory %s" % from)
		return
	
	var file_name = directory.get_next()
	
	while file_name != "":
		if directory.current_is_dir():
			copy_recursive(from + "/" + file_name, to + "/" + file_name)
		else:
			directory.copy(from + "/" + file_name, to + "/" + file_name)
		
		file_name = directory.get_next()

func copy_file(from: String, to: String) -> void:
	var directory = Directory.new()
	
	if directory.copy(from, to) != OK:
		printerr("Failed to copy file from %s to %s" % [from, to])



