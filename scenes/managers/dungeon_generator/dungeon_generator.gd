extends Node

const ROOM_1 = preload("res://scenes/rooms/room_1/room_1.tscn")
const ROOM_2 = preload("res://scenes/rooms/room_2/room_2.tscn")
const ROOM_3 = preload("res://scenes/rooms/room_3/room_3.tscn")
const ROOM_4 = preload("res://scenes/rooms/room_4/room_4.tscn")

const base_double_room_chance : float = 0.4
const base_triple_room_chance : float = 0.2
const base_quadruple_room_chance : float = 0.1

var double_room_chance : float
var triple_room_chance : float
var quadruple_room_chance : float

# used to iterate over empty adjacent cells and generate new rooms
var dungeon_grid : Array = []

var floor_modifier : int = 1
var number_of_rooms_to_generate : int

var spawn_room : Room
var dungeon_rooms : Array[Room]

func _ready() -> void:
	_generate_dungeon()
	%Button.pressed.connect(_generate_dungeon)


func _generate_dungeon() -> void:
	for room in dungeon_rooms:
		room.queue_free()
	
	dungeon_rooms = []
	dungeon_grid = []
	number_of_rooms_to_generate = 0
	
	_initialize_number_of_rooms()
	_initialize_room_chance_variables()
	_initialize_grid()
	_generate_spawn_room()
	_generate_base_rooms()
	#TODO generate special rooms x+randint 0,and floor number
	#TODO generate boss room
	#TODO room layouts, how to create and save them
	#TODO create tool to design them? When they spawn they fetch relevant enemy and stuff?


func _generate_base_rooms() -> void:
	while number_of_rooms_to_generate > 0:
		var new_room := _create_and_place_room()
		dungeon_rooms.append(new_room)
		_connect_room(new_room)
		number_of_rooms_to_generate -= 1


func _connect_room(room:Room) -> void:
	var unconnected_doorways : Array[Array] = []
	var neighbors : Array[Room] = _get_neighbors(room)
	neighbors.shuffle()
	for random_room in neighbors:
		var adjacent_cells : Array[Array] = _get_adjacent_cells(room, random_room)
		for cells in adjacent_cells:
			unconnected_doorways = _get_unconnected_doorway_pairs(room,random_room,adjacent_cells)
	
	if unconnected_doorways.is_empty():
		return
	
	var doorways_to_connect : Array= unconnected_doorways.pick_random()
	_connect_doorways(doorways_to_connect[0],doorways_to_connect[1])


func _connect_doorways(doorway_1:DoorwayComponent,doorway_2:DoorwayComponent)->void:
	doorway_1.other_doorway = doorway_2
	doorway_2.other_doorway = doorway_1


# All non-special rooms should have at least 2 connected doorways
func _validate_minimum_room_connections(room:Room) -> bool:
	return false



func _get_unconnected_doorway_pairs(room_1:Room,room_2:Room,adjacent_cells:Array[Array])->Array[Array]:
	var unconnected_doorway_pairs : Array[Array] = []
	for cell_pair in adjacent_cells:
		var doorway_1 : DoorwayComponent = room_1.get_doorway(cell_pair[1])
		var doorway_2 : DoorwayComponent = room_2.get_doorway(cell_pair[0])
		if (doorway_1 == null or doorway_2 == null) or (doorway_1.other_doorway != null and doorway_2.other_doorway):
			continue
		
		unconnected_doorway_pairs.append([doorway_1,doorway_2])
	
	return unconnected_doorway_pairs


func _are_doorways_connected(doorway_1:DoorwayComponent,doorway_2:DoorwayComponent) -> bool:
	return doorway_1.other_doorway == doorway_2 and doorway_2.other_doorway == doorway_1


func _get_room_from_cell(c:Vector2) -> Room:
	for room in dungeon_rooms:
		for cell in room.get_cells():
			if c == cell:
				return room
	return null


func _get_adjacent_cells(room_1:Room,room_2:Room) -> Array[Array]:
	var adjacent_cells : Array[Array] = []
	for cell_1 in room_1.dungeon_grid_cells_occupied:
		for cell_2 in room_2.dungeon_grid_cells_occupied:
			var delta_x = abs(cell_1.x - cell_2.x)
			var delta_y = abs(cell_1.y - cell_2.y)
			if delta_x + delta_y == 1:
				adjacent_cells.append([cell_1,cell_2])
	return adjacent_cells


func _get_neighbors(room:Room)-> Array[Room]:
	var neighbors : Array[Room] = []
	for exit in room.get_exits():
		var current_room := _get_room_from_cell(exit)
		if current_room != null:
			if not neighbors.has(current_room):
				neighbors.append(current_room)
	return neighbors

func _initialize_grid() -> void:
	var modifier := floor_modifier*5*2
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
	var room : Room
	match room_shape.room_type:
		1:
			room = ROOM_1.instantiate()
		2:
			room = ROOM_2.instantiate()
		3:
			room = ROOM_3.instantiate()
		4:
			room = ROOM_4.instantiate()
	
	add_child(room)
	room.set_room_shape(room_shape)
	return room


func _set_room_position(room:Room,position:Vector2) -> void:
	room.set_room_position(position)


func _create_and_place_room() -> Room:
	var room_location : Vector2 = _get_all_empty_adjacent_cells().pick_random()
	var room_shape : RoomShape = _get_random_room_type()
	var attempts : int = 0
	while not find_fit(room_location,room_shape):
		room_location = _get_all_empty_adjacent_cells().pick_random()
		attempts += 1
		if attempts > 10:
			print("No possible room could fit, choosing base room")
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
		room_type = "2"
	#elif random_float < quadruple_room_chance + triple_room_chance:
		#triple_room_chance /= (8-float(floor_modifier)/2)
		#room_type = "3"
	elif random_float < quadruple_room_chance + triple_room_chance + double_room_chance:
		double_room_chance /= (8-float(floor_modifier)/4)
		room_type = "2"
	else:
		room_type = "1"
	
	return RoomShape.new(room_type)


func _initialize_number_of_rooms() -> void:
	number_of_rooms_to_generate = 4  + (floor_modifier * 2) + randi_range(0,2)


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
	var rotations = [0.0,90,180,270]
	rotations.shuffle()

	var flips = [false, true]
	flips.shuffle()

	for rotation in rotations:
		for flip in flips:
			room_shape.reset_rotation()
			#TODO probably need to do the same reset for flipping the thing
			room_shape.flip_h = false
			room_shape.rotate(rotation) 
			room_shape.flip(flip)
			
			if does_room_fit(room_shape, potential_position):
				return true
	return false

# 2. Connects room as they are placed. Connections are chosen at random.
# 2.5 All rooms that have more than one neighbor should have two connections each
# 3. Once complete place special rooms. They only have one entrance to a non-special room.
# 3.5 boss room should be at least two spaces away from entrance
# 4. RoomShapes select their layout randomly, based on doors and type of room
# 5. generate mini-map from this?
# 6. spawn player
