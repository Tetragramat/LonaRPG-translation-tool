extends Node

const CONFIG_PATH: String = "user://config.cfg"

var config: ConfigFile = ConfigFile.new()

func _ready() -> void:
	print_debug("Loading config from path: " + ProjectSettings.globalize_path(CONFIG_PATH))
	
	if config.load(CONFIG_PATH) != OK:
		printerr("Cannot open config file")

func set_game_path(path: String) -> void:
	config.set_value("General", "game_path", path)
	
	if config.save(CONFIG_PATH) != OK:
		printerr("Cannot save config file")

func get_game_path() -> String:
	if config.has_section_key("General", "game_path"):
		return config.get_value("General", "game_path")
	
	return "res://"

func set_window_always_on_top(enabled: bool) -> void:
	config.set_value("General", "window_always_on_top", enabled)

	if config.save(CONFIG_PATH) != OK:
		printerr("Cannot save config file")

func get_window_always_on_top() -> bool:
	if config.has_section_key("General", "window_always_on_top"):
		return config.get_value("General", "window_always_on_top")
	
	return true
