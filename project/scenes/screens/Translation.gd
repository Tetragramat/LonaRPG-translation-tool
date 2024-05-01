extends "AbstractScreen.gd"

@onready var _label: RichTextLabel = $Panel/MarginContainer/VBoxContainer/RichTextLabel
@onready var _progress_bar: ProgressBar = $Panel/MarginContainer/VBoxContainer/ProgressBar
@onready var _translator_option_button: OptionButton = $Panel/MarginContainer/VBoxContainer/TranslatorOptionButton
@onready var _start_button: Button = $Panel/MarginContainer/VBoxContainer/HBoxContainer/BeginButton
@onready var _data: LocalizationData = get_node("/root/LocalizationData")
@onready var _translator: Translator = Translator.new(_data.get_language(), _data.get_target_dir())

var _extracted_data := {}
var _translated_data := {}

func _ready():
	_start_button.disabled = true
	_translator_option_button.add_item("Google Translate", 1)
	_translator_option_button.set_item_metadata(1, $Google)

func _on_translator_option_button_item_selected(index):
	if index > 0:
		_start_button.disabled = false
	else:
		_start_button.disabled = true

func _on_begin_button_pressed():
	_extracted_data = _translator.get_untranslated()
	
	if _extracted_data.is_empty():
		_label.add_text(str("\nThere is nothing to translate.\n"))
		return
	
	_translator_option_button.disabled = true
	_start_button.disabled = true
	_progress_bar.max_value = _extracted_data.size()
	_progress_bar.value = 0;
	
	var node: Google = _translator_option_button.get_selected_metadata()
	node.translate(_extracted_data.keys(), "zh-CN", _data.get_language())

func _on_cancel_button_pressed():
	emit_signal("next_screen", "configuration")

func _on_google_translation_progress(translations: Dictionary):
	_translated_data.merge(translations)
	_progress_bar.value = _translated_data.size()
	_translator.apply_translations(translations)
	
	_label.add_text(str("Progress... Translated %d lines.\n" % translations.size()))
	
	if _translated_data.size() == _extracted_data.size():
		_label.add_text(str("\nTranslation is complete. Start LonaRPG and switch language to MTL.\n\n"))
		_start_button.disabled = false
		_translator_option_button.disabled = false
		_translated_data.clear()
		_extracted_data.clear()

