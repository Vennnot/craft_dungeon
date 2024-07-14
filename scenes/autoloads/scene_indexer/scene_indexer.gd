extends Node

var enemies_folder : String = "res://scenes/enemies/"
var enemies_dictionary : Dictionary = {}

func _ready():
	_initialize()


func _initialize()->void:
	load_enemies()
	print(enemies_dictionary)


func load_enemies() -> void:
	for enemy in find_scene_files(enemies_folder):
		load_and_store_scene(enemy)


func load_obstacles()-> void:
	pass



func find_scene_files(parent_folder_path:String) -> PackedStringArray:
	var scene_file_array : PackedStringArray = []
	var dir = DirAccess.open(parent_folder_path)
	if dir:
		dir.list_dir_begin()
		var folder_name = dir.get_next()
		while folder_name != "":
			if dir.current_is_dir() and folder_name != "." and folder_name != "..":
				var folder_path :String= parent_folder_path + "/" + folder_name
				var scene_file := find_scene_file(folder_path)
				if scene_file:
					scene_file_array.append(scene_file)
			folder_name = dir.get_next()
		dir.list_dir_end()
	return scene_file_array



func find_scene_file(folder_path) -> String:
	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn"):
				return folder_path + "/" + file_name
			file_name = dir.get_next()
		dir.list_dir_end()
	return ""

func load_and_store_scene(scene_file) -> void:
	var packed_scene := load(scene_file)
	if packed_scene:
		var instance : Node2D = packed_scene.instantiate()
		if instance:
			enemies_dictionary[scene_file] = instance.tags
			instance.queue_free()

