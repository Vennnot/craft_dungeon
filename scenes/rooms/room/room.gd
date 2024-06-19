extends Node2D
class_name Room


var room_shape : RoomShape

var dungeon_grid_position : Vector2

# 1 means they are connected
var connected_exits : Dictionary = {}

func set_room_shape(new_room_shape:RoomShape)->void:
	room_shape = new_room_shape
	set_rotation(deg_to_rad(room_shape.rotation))
	set_flipped(room_shape.flip_h)


func _load_debug_shapes() -> void:
	var color : Color
	
	match room_shape.room_type:
		0:
			color = Color.RED
		1:
			color = Color.BLUE
		2:
			color = Color.PURPLE
		3:
			color = Color.GREEN
	
	print("---")
	print(dungeon_grid_position)
	print(room_shape.shape)
	print("---")
	
	for cell in room_shape.shape:
		var sprite := Sprite2D.new()
		add_child(sprite)
		sprite.position = cell*32
		sprite.texture = load("res://icon.svg")
		sprite.scale = Vector2(0.25,0.25)
		sprite.self_modulate = color


func set_room_position(pos:Vector2) -> void:
	position.x = pos.x
	position.y = pos.y
	_load_debug_shapes()


func set_dungeon_grid_position(grid_pos:Vector2) -> void:
	dungeon_grid_position = grid_pos


func set_flipped(flip_h:bool) -> void:
	if flip_h:
		scale.y = -1
	else:
		scale.y = 1


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
		cells.append(Vector2(cell.x+dungeon_grid_position.x,cell.y+dungeon_grid_position.y))
	return cells
