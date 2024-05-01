extends Node

var current_screen
var screens = {
		"configuration": preload("res://scenes/screens/Configuration.tscn"),
		"translation": preload("res://scenes/screens/Translation.tscn"),
		"manual_translate": preload("res://scenes/screens/ManualTranslate.tscn"),
	}

func _ready():
	current_screen = find_child("Screen")
	_load_screen("configuration")

func _load_screen(screen_name):
	if screen_name in screens:
		var old_screen = null
		if current_screen.get_child_count() > 0:
			old_screen = current_screen.get_child(0)
		if old_screen != null:
			current_screen.remove_child(old_screen)
		
		var new_screen = screens[screen_name].instantiate()
		new_screen.connect("next_screen", Callable(self, "_load_screen"))
		current_screen.add_child(new_screen)
	else:
		printerr("[ERROR] Cannot load screen: ", screen_name)
