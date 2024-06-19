extends Node2D
class_name Room

var room_shape : RoomShape

var dungeon_grid_location : Vector2

# 1 means they are connected
var connected_exits : Dictionary = {}

func set_room_shape(new_room_shape:RoomShape)->void:
	room_shape = new_room_shape
	set_rotation(room_shape.rotation)
	set_flipped(room_shape.flip_h)


func set_room_position(pos:Vector2) -> void:
	position.x = pos.x
	position.y = pos.y


func set_dungeon_grid_position(grid_pos:Vector2) -> void:
	dungeon_grid_location = grid_pos


func set_flipped(flip_h:bool) -> void:
	if flip_h:
		scale.x = -1
	else:
		scale.x = 1


func get_exits(multiplier:int)-> Array[Vector2]:
	var exits : Array[Vector2] = room_shape.exits
	for exit in exits:
		exit.x *= multiplier
		exit.x += position.x
		
		exit.y *= multiplier
		exit.y += position.y
	
	return exits


func get_cells() -> Array[Vector2]:
	var cells : Array[Vector2] = []
	for cell in room_shape.shape:
		cells.append(Vector2(cell.x+dungeon_grid_location.x,cell.y+dungeon_grid_location.y))
	return cells
