extends Cache

class_name Translator

var text_manager = TextManager.new()
var language: String
var textDir: String

func _init(lang: String, dir: String):
	language = lang
	textDir = dir

func get_untranslated() -> Dictionary:
	# load and apply cache
	var cached_lines = load_cache(language)
	
	if not cached_lines.is_empty():
		text_manager.extract(textDir) # there only because extract is required before import
		text_manager.import(textDir, cached_lines)
	
	# extract again after cache was applied
	return text_manager.extract(textDir)

func apply_translations(translations: Dictionary):
	text_manager.import(textDir, translations)
	
	# update cache
	var cached_lines = load_cache(language)
	cached_lines.merge(translations, true)
	save_cache(cached_lines, language)
