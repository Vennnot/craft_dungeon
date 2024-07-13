extends Node


var cell_button_scene : PackedScene = preload("res://scenes/tools/cell_layout_button/cell_layout_button.tscn")

#load and cache all special rooms

#only load chosen default rooms and cache them

func get_layout() -> RoomLayout:
	return load("res://resources/room_layouts/room_1/special/0000_r1_easy.tres")
	#room size
	#floor number
	#type of room


func load_layout(room:Room) -> void:
	#spawn and load shit
	#when floor starts this layout cannot change
	#for now let's just spawn the cells in the right positions
	print("Room position: %s"% room.position)
	for i in 9:
		for j in 9:
			var cell_button_instance := cell_button_scene.instantiate()
			add_child(cell_button_instance)
			cell_button_instance.z_index = 10
			cell_button_instance.position = (room.position-Vector2(8,8))+Vector2((i-(9/2))*16,(j-(9/2))*16)
			print(cell_button_instance.position)
