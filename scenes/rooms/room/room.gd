extends Node2D
class_name Room

#176 if rooms should be close
#240 if far
const room_length : int = 176

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
		doorway.active_room.connect(_on_doorway_entered)


func _on_doorway_entered() -> void:
	_set_camera_path()


func _set_camera_path() -> void:
	var room_path : String = Camera.get_path_to(camera_collision.get_child(0))
	var final_path := "../"+room_path
	Camera.set_limit_target(final_path)


func set_room_shape(new_room_shape:RoomShape)->void:
	room_shape = new_room_shape
	set_rotate()

func set_room_position(pos:Vector2) -> void:
	set_dungeon_grid_position(pos)
	adjust_doorways()
	
	position.x = pos.x * room_length
	position.y = pos.y * room_length
	
	#center rooms
	#for normal x and y rooms no actions is required
	#for twice as long x or y the room needs to be moved by one length to the right
	if is_equal_approx(room_shape.rotation, 0):
		if room_shape.room_type != room_shape.ROOM_TYPE.ONE:
			position.x += cell_size*5.5
			if room_shape.room_type == room_shape.ROOM_TYPE.TWO:
				pass
			else:
				position.y += cell_size*5.5
	
	elif is_equal_approx(room_shape.rotation, 90):
		position.y += cell_size*5.5
		if room_shape.room_type == room_shape.ROOM_TYPE.THREE:
			position.x -= cell_size*5.5

	elif is_equal_approx(room_shape.rotation, 180):
		if room_shape.room_type == room_shape.ROOM_TYPE.THREE:
			position.x -= cell_size*5.5
			position.y -= cell_size*5.5
	
	elif is_equal_approx(room_shape.rotation, 270):
		if room_shape.room_type == room_shape.ROOM_TYPE.THREE:
			position.x += cell_size*5.5
			position.y -= cell_size*5.5


func set_dungeon_grid_position(grid_pos:Vector2) -> void:
	dungeon_grid_position = grid_pos
	for cell in room_shape.shape:
		dungeon_grid_cells_occupied.append(grid_pos+cell)


func set_rotate() -> void:
	if room_shape.room_type == room_shape.ROOM_TYPE.TWO or room_shape.room_type == room_shape.ROOM_TYPE.THREE:
		set_rotation(deg_to_rad(room_shape.rotation))



func get_exits()-> Array[Vector2]:
	var exits : Array[Vector2] = []
	for exit in room_shape.exits:
		exits.append(Vector2(exit.x+dungeon_grid_position.x,exit.y+dungeon_grid_position.y))
	return exits

func get_empty_doorways() -> Array[DoorwayComponent]:
	var empty_doorways :Array[DoorwayComponent]= []
	for doorway in doorway_array:
		if doorway.other_doorway == null:
			empty_doorways.append(doorway)
	return empty_doorways


func get_cells() -> Array[Vector2]:
	var cells : Array[Vector2] = []
	for cell in room_shape.shape:
		cells.append(Vector2(cell.x+dungeon_grid_position.x,cell.y+dungeon_grid_position.y))
	return cells


func has_cell(cell:Vector2) -> bool:
	return get_cells().has(cell)


func adjust_doorways() -> void:
	for doorway in doorway_array:
		doorway.rotate_vector(room_shape.rotation)
		doorway.doorway_room_vector += dungeon_grid_position
		doorway.current_room_cell_vector += dungeon_grid_position

func get_doorway(v:Vector2) -> DoorwayComponent:
	for doorway in doorway_array:
		if doorway.doorway_room_vector == v:
			return doorway
	return null


func get_doorways(v:Vector2) -> Array[DoorwayComponent]:
	var dw_array : Array[DoorwayComponent] = []
	for doorway in doorway_array:
		if doorway.doorway_room_vector == v:
			dw_array.append(doorway)
	return dw_array
