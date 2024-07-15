extends Node

@export var boss_rooms_group : ResourceGroup
@export var item_rooms_group : ResourceGroup
@export var crafting_rooms_group : ResourceGroup
@export var shop_rooms_group : ResourceGroup

@export var room_1_group : ResourceGroup
@export var room_2_group : ResourceGroup
@export var room_3_group : ResourceGroup
@export var room_4_group : ResourceGroup

var boss_rooms : Array[RoomLayout]
var item_rooms : Array[RoomLayout]
var crafting_rooms : Array[RoomLayout]
var shop_rooms : Array[RoomLayout]

var r1_rooms : Array[RoomLayout]
var r2_rooms : Array[RoomLayout]
var r3_rooms : Array[RoomLayout]
var r4_rooms : Array[RoomLayout]



func _ready() -> void:
	pass


func get_layout(room:Room) -> RoomLayout:
	#TODO search correct room folder according to size
	#TODO choose correct folder based on special or default
	#TODO limit it to have exits open that exist
	#TODO difficulty based on floor. This is ignored if room is special
	#also ignored if results are null due to exits
	return load("res://resources/room_layouts/room_1/special/0000_r1_easy.tres")






var cell_button_scene : PackedScene = preload("res://scenes/tools/cell_layout_button/cell_layout_button.tscn")

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
