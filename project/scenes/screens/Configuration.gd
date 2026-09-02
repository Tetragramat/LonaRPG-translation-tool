extends Control

const GoogleLocales = preload("res://scripts/locales.gd")

const _manual_translate: PackedScene = preload("res://scenes/screens/ManualTranslate.tscn")
const _translate: PackedScene = preload("res://scenes/screens/Translation.tscn")

@onready var _language_option_button: OptionButton = $MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/LanguageOptionButton
@onready var _google_translate_button: Button = $MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/HBoxContainer/GoogleTranslateButton
@onready var _manual_translate_button: Button = $MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/HBoxContainer/ManualTranslateButton
@onready var _always_on_top_button: CheckButton = $AlwaysOnTopButton
@onready var _file_dialog: FileDialog = $FileDialog
@onready var _accept_dialog: AcceptDialog = $AcceptDialog

func _ready() -> void:
	_always_on_top_button.set_pressed(Config.get_window_always_on_top())
	setup_language_option_button()
	get_viewport().files_dropped.connect(_on_files_dropped)
	_parse_cmdline()

func _parse_cmdline() -> void:
	for argument in OS.get_cmdline_args():
		if not argument.contains("res://") and argument.is_absolute_path():
			game_file_selected(argument)
		break

func _process(_delta) -> void:
	_language_option_button.disabled = LocalizationData.text_directory.is_empty()
	_google_translate_button.disabled = LocalizationData.language_directory.is_empty() or LocalizationData.language.is_empty()
	_manual_translate_button.disabled = LocalizationData.language_directory.is_empty() or LocalizationData.language.is_empty()

func _on_SelectGameButton_pressed() -> void:
	_file_dialog.popup_centered()
	_file_dialog.set_current_dir(Config.get_game_path().get_base_dir())

func _on_files_dropped(files: PackedStringArray, _screen: int) -> void:
	_file_dialog.hide()
	game_file_selected(files[0])

func _on_FileDialog_file_selected(path: String) -> void:
	_file_dialog.hide()
	game_file_selected(path)

func _on_LanguageOptionButton_item_selected(index: int) -> void:
	LocalizationData.language = _language_option_button.get_item_metadata(index)
	
	match LocalizationData.get_language():
		"en":
			LocalizationData.language_directory = "ENG"
		"ko":
			LocalizationData.language_directory = "KOR"
		"ru":
			LocalizationData.language_directory = "RUS"
		"uk":
			LocalizationData.language_directory = "UKR"
		_:
			LocalizationData.language_directory = "CHT"
	
	if not DirAccess.dir_exists_absolute(LocalizationData.get_source_dir()):
		printerr("Source directory %s does not exist reverting back to default CHT directory." % LocalizationData.get_source_dir())
		LocalizationData.language_directory = "CHT"
	
	copy_recursive(LocalizationData.get_source_dir(), LocalizationData.get_target_dir())

func _on_GoogleTranslateButton_pressed() -> void:
	add_child(_translate.instantiate())

func _on_ManualTranslateButton_pressed() -> void:
	add_child(_manual_translate.instantiate())

func _on_AlwaysOnTopButton_toggled(button_pressed: bool) -> void:
	Config.set_window_always_on_top(button_pressed)
	get_window().always_on_top = (button_pressed)

func game_file_selected(path: String) -> void:
	var text_dir: String = path.get_base_dir() + "/Text"

	if not DirAccess.dir_exists_absolute(text_dir):
		_accept_dialog.dialog_text =  "Directory " + text_dir + " does not exist!"
		_accept_dialog.popup_centered()
		return

	LocalizationData.text_directory = text_dir
	LocalizationData.game_directory = path.get_base_dir()

	Config.set_game_path(path)
	copy_file(LocalizationData.get_image_source(), LocalizationData.get_image_target())

func setup_language_option_button() -> void:
	_language_option_button.add_item("Select language", 0)
	_language_option_button.set_item_metadata(0, "")
	
	var index: int = 1
	for item in GoogleLocales.LOCALES:
		_language_option_button.add_item(item["name"], index)
		_language_option_button.set_item_metadata(index, item["code"])
		index = index + 1

func copy_recursive(from: String, to: String) -> void:
	if not DirAccess.dir_exists_absolute(to):
		if DirAccess.make_dir_recursive_absolute(to) != OK:
			printerr("Failed to create directory %s" % to)
			return
	
	var directory: DirAccess = DirAccess.open(from)
	
	if not directory:
		printerr("Unable to open directory %s" % from)
		return
	
	if directory.list_dir_begin() != OK:
		printerr("Unable to list directory %s" % from)
		return
	
	var file_name: String = directory.get_next()
	
	while file_name != "":
		if directory.current_is_dir():
			copy_recursive(from + "/" + file_name, to + "/" + file_name)
		else:
			directory.copy(from + "/" + file_name, to + "/" + file_name)
		
		file_name = directory.get_next()

func copy_file(from: String, to: String) -> void:
	if DirAccess.copy_absolute(from, to) != OK:
		printerr("Failed to copy file from %s to %s" % [from, to])
