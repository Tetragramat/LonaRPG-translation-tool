extends Node

const CONFIG_PATH = "user://config.cfg"

var _config = ConfigFile.new()

func _ready():
	if _config.load(CONFIG_PATH) != OK:
		print("Cannot open config file")

func set_game_path(path: String) -> void:
	_config.set_value("General", "game_path", path)
	_config.save(CONFIG_PATH)

func get_game_path() -> String:
	if _config.has_section_key("General", "game_path"):
		return _config.get_value("General", "game_path")
	
	return "res://"

func set_window_always_on_top(enabled: bool) -> void:
	_config.set_value("General", "window_always_on_top", enabled)
	_config.save(CONFIG_PATH)

func get_window_always_on_top() -> bool:
	if _config.has_section_key("General", "window_always_on_top"):
		return _config.get_value("General", "window_always_on_top")
	
	return true
