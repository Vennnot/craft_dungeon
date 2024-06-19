extends Node

@export var room_template : PackedScene = preload("res://scenes/rooms/room/room.tscn")

const base_point : Vector2 = Vector2(500,300)
const room_length : float = 32
const base_double_room_chance : float = 0.4
const base_triple_room_chance : float = 0.2
const base_quadruple_room_chance : float = 0.1

var double_room_chance : float
var triple_room_chance : float
var quadruple_room_chance : float

# used to iterate over empty adjacent cells and generate new rooms
var dungeon_grid : Array = []

var floor_modifier : int = 2
var number_of_rooms_to_generate : int

var spawn_room : Room
var dungeon_rooms : Array[Room]

func _ready() -> void:
	_generate_dungeon()
	$Button.pressed.connect(_generate_dungeon)
	
	#TODO if no room fits, regenerate a room
	#TODO if room failed to generate try different exit and different room
	#generate next room by iterating over empty exits
	#TODO connect the rooms and their exits
	#TODO fetch room from vector2D
	#then continue until all rooms are generated
	#TODO create more connections in rooms before setting in stone
	#then generate special rooms and connect them


func _generate_dungeon() -> void:
	for room in dungeon_rooms:
		room.queue_free()
	
	dungeon_rooms = []
	dungeon_grid = []
	
	_initialize_number_of_rooms()
	_initialize_room_chance_variables()
	_initialize_grid()
	_generate_spawn_room()
	_generate_base_rooms()

func _generate_base_rooms() -> void:
	while number_of_rooms_to_generate > 0:
		var room := _create_and_place_room()
		dungeon_rooms.append(room)
		#TODO if for some reason fails, try new empty cell and new room shape
		#TODO connect previous room to current room
		#TODO update grid
		#TODO track last placed room
		number_of_rooms_to_generate -= 1



func _initialize_grid() -> void:
	var modifier := floor_modifier*5
	for i in modifier:
		var row := []
		for j in modifier:
			row.append(0)
		dungeon_grid.append(row)


func _generate_spawn_room() -> void:
	@warning_ignore("integer_division")
	var base_number : Vector2 = Vector2(floor_modifier*5/2,floor_modifier*5/2)
	base_number.x += (randi_range(-floor_modifier,floor_modifier))
	base_number.y += (randi_range(-floor_modifier,floor_modifier))
	_occupy_dungeon_cell(base_number)
	spawn_room = _instantiate_room(RoomShape.new("1"))
	_set_room_position(spawn_room,base_number)
	dungeon_rooms.append(spawn_room)


func _occupy_dungeon_cell(cell:Vector2) -> void:
	if dungeon_grid[cell.x][cell.y] == 1:
		print("Error! Cell is already occupied!")
	dungeon_grid[cell.x][cell.y] = 1


func _instantiate_room(room_shape:RoomShape) -> Room:
	var room : Room = room_template.instantiate()
	add_child(room)
	room.set_room_shape(room_shape)
	return room


func _set_room_position(room:Room,position:Vector2) -> void:
	room.set_dungeon_grid_position(position)
	room.set_room_position((position*room_length))


func _create_and_place_room() -> Room:
	var room_location : Vector2 = _get_all_empty_adjacent_cells().pick_random()
	var room_shape := _get_random_room_type()
	var attempts : int = 0
	while not find_fit(room_location,room_shape):
		room_location = _get_all_empty_adjacent_cells().pick_random()
		attempts += 1
		if attempts > 10:
			room_shape = RoomShape.new("1")
	
	var room : Room = _instantiate_room(room_shape)
	_set_room_position(room, room_location)
	for cell in room.get_cells():
		_occupy_dungeon_cell(cell)
	
	return room



func _initialize_room_chance_variables() -> void:
	double_room_chance = base_double_room_chance
	triple_room_chance = base_triple_room_chance
	quadruple_room_chance = base_quadruple_room_chance


func _get_random_room_type() -> RoomShape:
	randomize()
	var random_float := randf_range(0,1)
	var room_type : String
	if random_float < quadruple_room_chance:
		#FIXME this random ass decrease needs to make more sense
		quadruple_room_chance /= (8-float(floor_modifier))
		room_type = "4"
	elif random_float < quadruple_room_chance + triple_room_chance:
		triple_room_chance /= (8-float(floor_modifier)/2)
		room_type = "3"
	elif random_float < quadruple_room_chance + triple_room_chance + double_room_chance:
		double_room_chance /= (8-float(floor_modifier)/4)
		room_type = "2"
	else:
		room_type = "1"
	
	return RoomShape.new(room_type)


func _initialize_number_of_rooms() -> void:
	number_of_rooms_to_generate = 2
#4 + (floor_modifier * 2) + randi_range(0,2)


func _get_all_empty_adjacent_cells() -> Array[Vector2]:
	var empty_adjacent_cells : Array[Vector2] = []
	for room in dungeon_rooms:
		var empty_room_cells : Array[Vector2] = []
		empty_room_cells = _get_empty_adjacent_cells_to_room(room)
		for cell in empty_room_cells:
			empty_adjacent_cells.append(cell)
	
	if empty_adjacent_cells.is_empty():
		print("No existing empty adjacent cells!")
	return empty_adjacent_cells

func _get_empty_adjacent_cells_to_room(room:Room) -> Array[Vector2]:
	var empty_adjacent_cells : Array[Vector2] = []
	for exit in room.room_shape.exits:
		var room_exit_location : Vector2 = Vector2(exit.x+room.dungeon_grid_position.x,exit.y+room.dungeon_grid_position.y)
		if _is_within_dungeon_grid(room_exit_location):
			if dungeon_grid[room_exit_location.x][room_exit_location.y] == 0:
				empty_adjacent_cells.append(room_exit_location)
	return empty_adjacent_cells


func _is_within_dungeon_grid(cell:Vector2) -> bool:
	if cell.x > dungeon_grid[0].size()-1 or cell.y > dungeon_grid[0].size()-1:
		return false
	return true

# Check if the room fits at the given position
func does_room_fit(room: RoomShape, position: Vector2) -> bool:
	for cell in room.move_to(position):
		if not _is_within_dungeon_grid(cell):
			return false
		elif not dungeon_grid.has(cell) and dungeon_grid[cell.x][cell.y] != 0:
			return false
	return true


# Find a fit for the room in a randomized order, returns true if a fit was found
func find_fit(potential_position: Vector2, room_shape:RoomShape) -> bool:
	if room_shape.room_type == 0:
		return does_room_fit(room_shape, potential_position)
	
	var rotations = [0.0, 90.0, 180.0, 270.0]
	rotations.shuffle()

	var flips = [false, true]
	flips.shuffle()

	for rotation in rotations:
		for flip in flips:
			room_shape.rotation = 0
			room_shape.flip_h = false
			room_shape.rotate(rotation) 
			room_shape.flip(flip)
			
			if does_room_fit(room_shape, potential_position):
				return true

	print("No possible room could fit")
	return false

# generate rooms on a grid
# 1. Can choose from multiple rooms, repetition and frequency depends on floor difficulty
# 2. Connects room as they are placed. Connections are chosen at random.
# 2.5 All rooms that have more than one neighbor should have two connections each
# 3. Once complete place special rooms. They only have one entrance to a non-special room.
# 3.5 boss room should be at least two spaces away from entrance
#4. RoomShapes select their layout randomly, based on doors and type of room
# 5. generate mini-map from this?
# 6. spawn player
