extends Node
class_name Google

const CHARACTER_LIMIT = 5000

signal translation_progress(translations: Dictionary)

@onready var _http_request: HTTPRequest = $HTTPRequest
@onready var _timer: Timer = $Timer

var source_language: String = ""
var target_language: String = ""
var _batches: Array = []

func translate(value: Array, from_language: String, to_language: String) -> void:
	source_language = from_language
	target_language = to_language
	create_batches(value)
	execute()

func create_batches(value: Array) -> void:
	_batches.clear()
	var content: String = ""
	
	for word in value:
		if str(content, word.uri_encode()).length() > 5000:
			_batches.append(content)
			content = ""
		
		content = content + str(word, "\n").uri_encode()
	
	if not content.is_empty():
		_batches.append(content)
		content = ""
	
	_batches.reverse()

func execute() -> void:
	var text = _batches.pop_back()
	
	if text == null or text.is_empty():
		return
	
	var client = HTTPClient.new()
	var query = "client=gtx&sl=%s&tl=%s&dt=t&q=%s" % [source_language, target_language, text]
	
	var url = "https://translate.googleapis.com/translate_a/single?%s" % query
	
	print_debug("HTTPRequest to Google api.\nRequest %s" % url)
	
	var response = _http_request.request(url, [], HTTPClient.METHOD_GET)
	
	if response != OK:
		printerr("Request failed %d" % response)
	
	_timer.start()

func _on_http_request_request_completed(result: HTTPRequest.Result, response_code: HTTPClient.ResponseCode, headers: PackedStringArray, body: PackedByteArray) -> void:
	print_debug("HTTPRequest to Google api.\nResult %d\nCode %d\nHeaders %s\nBody %s" % [result, response_code, headers, body.get_string_from_utf8()])
	
	if result != HTTPRequest.RESULT_SUCCESS:
		printerr("HTTPRequest to Google api failed.\nResult %d\nCode %d\nHeaders %s\nBody %s" % [result, response_code, headers, body.get_string_from_utf8()])
		return
	
	if response_code != HTTPClient.RESPONSE_OK:
		printerr("HTTPRequest to Google api failed.\nResult %d\nCode %d\nHeaders %s\nBody %s" % [result, response_code, headers, body.get_string_from_utf8()])
		return
	
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var content = json.get_data()
	
	var translated_text: String = ""
	var original_text: String = ""
	
	for item in content[0]:
		translated_text = translated_text + item[0]
		original_text = original_text + item[1]

	var translated_lines = []
	for item in translated_text.split("\n", false):
		translated_lines.append(item)
	
	var original_lines = []
	for item in original_text.split("\n", false):
		original_lines.append(item)
	
	if original_lines.size() != translated_lines.size():
		printerr("Amount of original %d and translated %d lines does not match!" % [original_lines.size(), translated_lines.size()])
		return
	
	var translations: Dictionary = {}
	var i = 0
	while i < translated_lines.size():
		translations[original_lines[i]] = translated_lines[i]
		i = i + 1
	
	translation_progress.emit(translations)

func _on_timer_timeout() -> void:
	execute()
