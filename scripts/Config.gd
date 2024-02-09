extends Node

const CONFIG_PATH = "user://config.cfg"

var config = ConfigFile.new()

func _ready():
	if config.load(CONFIG_PATH) != OK:
		print("Cannot open config file")

func set_game_path(path: String) -> void:
	config.set_value("General", "game_path", path)
	config.save(CONFIG_PATH)

func get_game_path() -> String:
	if config.has_section_key("General", "game_path"):
		return config.get_value("General", "game_path")
	
	return "res://"

func set_window_always_on_top(enabled: bool) -> void:
	config.set_value("General", "window_always_on_top", enabled)
	config.save(CONFIG_PATH)

func get_window_always_on_top() -> bool:
	if config.has_section_key("General", "window_always_on_top"):
		return config.get_value("General", "window_always_on_top")
	
	return true
