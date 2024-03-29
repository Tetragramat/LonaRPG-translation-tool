extends Object

class_name TextManager

var regex: RegEx = RegEx.new()
var extracted = []

func _init():
	if regex.compile("(*UTF)[\\N{U+4E00}-\\N{U+9FFF}\\N{U+3400}-\\N{U+4DBF}\\N{U+20000}-\\N{U+2A6DF}\\N{U+2A700}-\\N{U+2B73F}\\N{U+2B740}-\\N{U+2B81F}\\N{U+2B820}-\\N{U+2CEAF}\\N{U+F900}-\\N{U+FAFF}\\N{U+2F800}-\\N{U+2FA1F}？。！，]+") != OK:
		printerr("Unable to compile regex")

func import(path: String, translations: Dictionary) -> void:
	# translations contains extracted with removed duplicates
	var lines = extracted
	
	if lines.is_empty():
		return
	
	# replace original lines with translations
	for key in translations:
		# if translation is same as original then skip the value
		if key == translations[key]:
			continue
		
		var index = 0
		
		while true:
			index = lines.find(key, index)
			
			if index == -1:
				break
			else:
				lines.remove_at(index)
				lines.insert(index, translations[key])
	
	# invert array to make removing items faster
	lines.reverse()
	
	for file_path in list_dir_recursive(path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var content: String = file.get_as_text()
		file.close()
		
		var from_pos = 0
		for result in regex.search_all(content):
			var current_pos = content.find(result.get_string(), from_pos)
			content = content.erase(current_pos, result.get_string().length())
			content = content.insert(current_pos, lines.pop_back())
		
		file = FileAccess.open(file_path, FileAccess.WRITE)
		file.store_string(content)
		file.close()

func extract(path: String) -> Dictionary:
	extracted.clear()
	
	for file_path in list_dir_recursive(path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		
		for result in regex.search_all(content):
			extracted.append(result.get_string())
	
	var optimised = {}
	
	for line in extracted:
		optimised[line] = null
	
	return optimised

func list_dir_recursive(path: String) -> Array:
	var list = []
	var dir = DirAccess.open(path)
	
	if dir:
		if dir.list_dir_begin() != OK:
			printerr("Unable to list directory %s" % path)
		
		while true:
			var file = dir.get_next()
			var current_path = str(dir.get_current_dir(), "/", file)
			
			if file == "":
				break
			elif file.ends_with(".txt") and dir.file_exists(current_path):
				list.append(current_path)
			elif dir.dir_exists(current_path):
				list = list + list_dir_recursive(current_path)
		
		dir.list_dir_end()
	else:
		printerr("Unable to open directory %s" % path)
	
	return list




