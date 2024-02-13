extends "AbstractScreen.gd"

@onready var _label = $MarginContainer/VBoxContainer/RichTextLabel
@onready var _progress_bar = $MarginContainer/VBoxContainer/ProgressBar
@onready var _start_button = $MarginContainer/VBoxContainer/HBoxContainer/StartButton
@onready var _timer = $Timer
@onready var _data = get_node("/root/LocalizationData")
@onready var _translator: Translator = Translator.new(_data.get_language(), _data.get_target_dir())

var _extracted_data := {}
var _translated_data := {}
var _batches: Array = []

func _ready():
	extract()
	create_batches()
	_label.add_text(str("Automatic translation should take %.1f minutes to finish.\n" % [(_batches.size() * _timer.wait_time) / 60]))

func _process(_delta):
	if not _batches.is_empty() and _timer.is_stopped():
		_start_button.disabled = false
	else:
		_start_button.disabled = true

func _on_CancelButton_pressed():
	emit_signal("next_screen", "configuration")

func _on_StartButton_pressed():
	if _batches.is_empty() or not _timer.is_stopped():
		return
	
	_progress_bar.max_value = _batches.size()
	_progress_bar.value = 0
	
	_timer.start()

func _on_Timer_timeout():
	if _batches.is_empty():
		_timer.stop()
		import()
		_label.add_text(str("\nTranslation is complete. Start LonaRPG and switch language to MTL\n"))
		return
	
	create_request("zh-CN", _data.get_language(), _batches.pop_front())

func extract() -> void:
	_extracted_data = _translator.get_untranslated()

func import() -> void:
	_translator.apply_translations(_translated_data)
	_translated_data.clear()

func create_batches():
	_batches.clear()
	var content: String = ""
	
	for word in _extracted_data:
		if str(content, word.uri_encode()).length() > 5000:
			_batches.append(content)
			content = ""
		
		content = content + str(word, "\n").uri_encode()
	
	if not content.is_empty():
		_batches.append(content)
		content = ""

func create_request(from_language, to_language, value) -> void:
	var url = create_url(from_language, to_language, value)
	var http_request = HTTPRequest.new()
	
	http_request.timeout = 5
	add_child(http_request)
	
	http_request.connect("request_completed", Callable(self, "http_request_completed").bind(http_request))
	http_request.request(url, [], HTTPClient.METHOD_GET)

func create_url(from_language, to_language, value) -> String:
	var url = "https://translate.googleapis.com/translate_a/single?client=gtx"
	url += "&sl=" + from_language
	url += "&tl=" + to_language
	url += "&dt=t"
	url += "&q=" + value
	
	return url

func http_request_completed(result, response_code, _headers, body, http_request):
	remove_child(http_request)
	
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		_label.add_text(str("\nGoogle API request failed! Status code %d\n" % [response_code]))
		_label.add_text("\nYou exceeded maximum amount of requests. Wait for some time (from minutes to hours) and try it again.\n")
		_timer.stop()
		printerr("Request to Google API failed", body.get_string_from_utf8())
		return
	
	_progress_bar.value = _progress_bar.value + 1
	
	var test_json_conv = JSON.new()
	test_json_conv.parse(body.get_string_from_utf8())
	var result_body = test_json_conv.get_data()
	var translated_text := ""
	var original_text := ""
	
	for item in result_body[0]:
		translated_text = translated_text + item[0]
		original_text = original_text + item[1]
	
	var translated_lines = []
	for item in translated_text.split("\n", false):
		translated_lines.append(item)
	
	var original_lines = []
	for item in original_text.split("\n", false):
		original_lines.append(item)
	
	if translated_lines.size() != original_lines.size():
		printerr("Amount of original and translated does not match!")
		return
	
	var i = 0
	while i < translated_lines.size():
		_translated_data[original_lines[i]] = translated_lines[i]
		i = i + 1
	

