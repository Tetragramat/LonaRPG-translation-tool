extends Object

class_name Cache

func get_cache_file(locale: String) -> String:
	return "user://translations_" + locale + ".json"

func save_cache(items: Dictionary, locale: String) -> void:
	var json_string = JSON.stringify(items)
	var cacheFile = get_cache_file(locale)
	
	var file = FileAccess.open(cacheFile, FileAccess.WRITE)
	
	if file == null:
		printerr("Unable to create cache file ", cacheFile, " ERROR: ", FileAccess.get_open_error())
	
	file.store_string(json_string)
	file.close()

func load_cache(locale: String) -> Dictionary:
	var cacheFile = get_cache_file(locale)
	var file = FileAccess.open(cacheFile, FileAccess.READ)
	
	if file == null:
		print("Unable to open cache file ", cacheFile, " ERROR: ", FileAccess.get_open_error())
		return {}
	
	var json_string: String = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK:
		var data_received = json.data
		
		if typeof(data_received) == TYPE_DICTIONARY:
			return data_received
		else:
			printerr("Unexpected data")
	else:
		printerr("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	
	return {}
