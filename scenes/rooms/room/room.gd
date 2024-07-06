extends Node2D
class_name Room

const room_length : int = 272

const cell_size : int = 16

var room_shape : RoomShape

var dungeon_grid_position : Vector2
var dungeon_grid_cells_occupied : Array[Vector2]

var doorway_array : Array[DoorwayComponent]

@onready var camera_collision: Area2D = %CameraCollisionAreaComponent
@onready var tile_map: TileMap = %TileMap
@onready var doorways: Node2D = %Doorways


var doorway_tile_layer : int = 0

func _ready() -> void:
	_initialize_doorways()


func _initialize_doorways() -> void:
	for doorway in doorways.get_children():
		doorway_array.append(doorway)
		doorway.body_entered.connect(_on_doorway_entered.bind(doorway))


func _on_doorway_entered(body:Node2D, doorway:DoorwayComponent) -> void:
	if not body is Player:
		return
	
	var new_room : Room = doorway.get_parent().get_parent()
	var room_path : String = Camera.get_path_to(new_room.camera_collision.get_child(0))
	var final_path := "../"+room_path
	Camera.set_limit_target(final_path)


func set_room_shape(new_room_shape:RoomShape)->void:
	room_shape = new_room_shape
	set_rotate()
	set_flip(room_shape.flip_h)

func set_room_position(pos:Vector2) -> void:
	set_dungeon_grid_position(pos)
	adjust_doorways()
	
	position.x = pos.x * room_length
	position.y = pos.y * room_length
	
	#center rooms
	if is_equal_approx(room_shape.rotation, 0):
		if room_shape.room_type != room_shape.ROOM_TYPE.ONE:
			position.x += cell_size*8.5
			if room_shape.room_type == room_shape.ROOM_TYPE.TWO:
				position.y += cell_size*3
			else:
				position.y += cell_size*12
		else:
			position.y += cell_size*3
	
	elif is_equal_approx(room_shape.rotation, 90):
		if room_shape.room_type == room_shape.ROOM_TYPE.TWO:
			position.x += 0
			position.y += cell_size*8.5

	
	elif is_equal_approx(room_shape.rotation, 180):
		if room_shape.room_type == room_shape.ROOM_TYPE.TWO:
			position.x -= cell_size*8.5
			position.y += cell_size*3
		else:
			position.x += cell_size*8.5
			position.y += cell_size*12
#
	#elif is_equal_approx(room_shape.rotation, 270):
		#position.x += cell_size*10.5*2


func set_dungeon_grid_position(grid_pos:Vector2) -> void:
	dungeon_grid_position = grid_pos
	for cell in room_shape.shape:
		dungeon_grid_cells_occupied.append(grid_pos+cell)
	print("Position: %s" % dungeon_grid_position)
	print(dungeon_grid_cells_occupied)


func set_rotate() -> void:
	if room_shape.room_type == room_shape.ROOM_TYPE.TWO:
		set_rotation(deg_to_rad(room_shape.rotation))


func set_flip(flip_h:bool) -> void:
	if flip_h:
		scale.y = -1
	else:
		scale.y = 1


func get_exits()-> Array[Vector2]:
	var exits : Array[Vector2] = []
	for exit in room_shape.exits:
		exits.append(Vector2(exit.x+dungeon_grid_position.x,exit.y+dungeon_grid_position.y))
	return exits


func get_cells() -> Array[Vector2]:
	var cells : Array[Vector2] = []
	for cell in room_shape.shape:
		cells.append(Vector2(cell.x+dungeon_grid_position.x,cell.y+dungeon_grid_position.y))
	return cells


func has_cell(cell:Vector2) -> bool:
	return get_cells().has(cell)


func adjust_doorways() -> void:
	for doorway in doorway_array:
		doorway.doorway_room_vector += dungeon_grid_position
		doorway.rotate_vector(deg_to_rad(room_shape.rotation))
		doorway.flip_vector_horizontally(room_shape.flip_h)

func get_doorway(v:Vector2) -> DoorwayComponent:
	for doorway in doorway_array:
		if doorway.doorway_room_vector == v:
			return doorway
	return null 
