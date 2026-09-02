extends Control

@onready var _readme: RichTextLabel = $MarginContainer/VBoxContainer/RichTextLabel
@onready var _source_text: CodeEdit = $MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/SourceText
@onready var _target_text: CodeEdit = $MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer2/TargetText
@onready var _apply: Button = $MarginContainer/VBoxContainer/HBoxContainer2/ApplyButton
@onready var _translator: Translator = Translator.new(LocalizationData.get_language(), LocalizationData.get_target_dir())

var _translations: Dictionary[Variant, Variant] = {}
var _lines: Array[Variant] = []
var _filepath: String = ProjectSettings.globalize_path("user://translate.txt")
var _regex: RegEx = RegEx.new()

func _ready() -> void:
	_regex.compile("[^\\n\\r]+")
	_readme.text = str(_readme.text % [_filepath.get_file(), _filepath.get_base_dir()])
	extract()

func _process(_delta) -> void:
	_apply.disabled = _lines.is_empty()

func _on_CancelButton_pressed() -> void:
	get_parent().remove_child(self)

func _on_ApplyButton_pressed() -> void:
	import()
	extract()
	_target_text.text = ""

func _on_TargetText_text_changed() -> void:
	_lines.clear()
	
	for result in _regex.search_all(_target_text.text):
		_lines.append(result.get_string())
	
	if _lines.size() != _translations.size():
		print("Number of lines %d does not match number of translations %s" % [_lines.size(), _translations.size()])
		_lines.clear()
		return

func _on_RichTextLabel_meta_clicked(meta) -> void:
	if meta == _filepath.get_base_dir():
		DisplayServer.clipboard_set(meta)
		return
	
	OS.shell_open(str(meta))

func extract() -> void:
	_translations = _translator.get_untranslated()
	
	var text: String = ""
	for untranslated in _translations:
		text = text + untranslated + "\n"
	
	_source_text.text = text
	
	save_into_file(text)

func import() -> void:
	var i: int = 0
	for index in _translations:
		_translations[index] = _lines[i]
		i = i + 1
	
	_translator.apply_translations(_translations)
	_translations.clear()

func save_into_file(contents: String) -> void:
	var file: FileAccess = FileAccess.open(_filepath, FileAccess.WRITE)
	
	if not file:
		printerr("Unable to open file %s. %s" % [_filepath, FileAccess.get_open_error()])
		return
	
	file.store_string(contents)
	file.close()

func _on_target_text_caret_changed() -> void:
	_target_text.center_viewport_to_caret()
	_source_text.set_caret_line(_target_text.get_caret_line())

func _on_source_text_caret_changed() -> void:
	_source_text.center_viewport_to_caret()
	_target_text.set_caret_line(_source_text.get_caret_line())
