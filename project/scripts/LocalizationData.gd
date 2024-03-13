extends Node

const TARGET_DIRECTORY = "MTL"

var game_directory: String
var text_directory: String
var language_directory: String
var language: String

func get_language() -> String:
	return language

func get_source_dir() -> String:
	return text_directory + "/" + language_directory

func get_target_dir() -> String:
	return text_directory + "/" + TARGET_DIRECTORY

func get_image_source():
	return game_directory + "/Graphics/Pictures/WarningENG.png"

func get_image_target():
	return game_directory + "/Graphics/Pictures/WarningMTL.png"
