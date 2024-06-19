extends Node

const base_point : Vector2 = Vector2(500,300)
const room_diameter : float = 32
const base_double_room_chance : float = 0.4
const base_triple_room_chance : float = 0.2
const base_quadruple_room_chance : float = 0.1

var double_room_chance : float
var triple_room_chance : float
var quadruple_room_chance : float

var dungeon_grid : Array = []

var floor_modifier : int = 2

var number_of_rooms : int
var spawn_room : Room

# this cant be a vector, has to represent the actual rooms
var last_placed_room : Vector2

enum ROOM_TYPE {ONE,TWO,THREE,FOUR}

@onready var room_1: Node2D = %room1
@onready var room_2: Node2D = %room2
@onready var room_3: Node2D = %room3
@onready var room_4: Node2D = %room4

func _ready() -> void:
	_initialize_number_of_rooms()
	_initialize_grid()
	#_generate_spawn_room_location()
	_generate_base_rooms()
	
	print(dungeon_grid)
	var room := _get_random_room_type()
	print(room.shape)
	find_fit(Vector2.ZERO,room)
	print(room.shape)

func _initialize_grid() -> void:
	var modifier := floor_modifier*5
	for i in modifier:
		var row := []
		for j in modifier:
			row.append(0)
		dungeon_grid.append(row)


#TODO spawn the room
func _generate_spawn_room_location() -> void:
	@warning_ignore("integer_division")
	var base_number : Vector2 = Vector2(floor_modifier*5/2,floor_modifier*5/2)
	base_number.x += (randi_range(-floor_modifier,floor_modifier))
	base_number.y += (randi_range(-floor_modifier,floor_modifier))
	dungeon_grid[base_number.x][base_number.y] = 1
	#last_placed_room = dungeon_grid[base_number.x][base_number.y]



func _generate_base_rooms() -> void:
	_initialize_room_chance_variables()
	while number_of_rooms > 0:
		var room_to_generate := _get_random_room_type()
		#TODO connect previous room to current room
		#TODO update grid
		#TODO track last placed room
		number_of_rooms -= 1


func _initialize_room_chance_variables() -> void:
	double_room_chance = base_double_room_chance
	triple_room_chance = base_triple_room_chance
	quadruple_room_chance = base_quadruple_room_chance


func _get_random_room_type() -> Room:
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
	
	return Room.new(room_type)


func _initialize_number_of_rooms() -> void:
	number_of_rooms = 4 + (floor_modifier * 2) + randi_range(0,2)


func _get_empty_adjacent_cells(room:Room) -> Array[Vector2]:
	var empty_adjacent_cells := []
	for exit in room.exits:
		if dungeon_grid[exit.x][exit.y] == 0:
			empty_adjacent_cells.append(exit)
	return empty_adjacent_cells


# Check if the room fits at the given position
func does_room_fit(room: Room, position: Vector2) -> bool:
	for cell in room.move_to(position):
		if not dungeon_grid.has(cell) and dungeon_grid[cell.x][cell.y] != 0:
			return false
	return true


# Find a fit for the room in a randomized order
func find_fit(base_position: Vector2, room:Room) -> bool:
	var max_attempts := 3
	var attempt := 0

	while attempt < max_attempts:
		var rotations = [0.0, 90.0, 180.0, 270.0]
		rotations.shuffle()

		var flips = [false, true]
		flips.shuffle()

		for rotation in rotations:
			for flip in flips:
				room.rotation = 0
				room.flip_h = false
				room.rotate(rotation) 
				room.flip(flip)
				
				if does_room_fit(room, base_position):
					print("Found valid orientation")
					return true
		attempt += 1

	print("No possible room could fit after 3 attempts")
	return false

# generate rooms on a grid
# 1. Can choose from multiple rooms, repetition and frequency depends on floor difficulty
# 2. Connects room as they are placed. Connections are chosen at random.
# 2.5 All rooms that have more than one neighbor should have two connections each
# 3. Once complete place special rooms. They only have one entrance to a non-special room.
# 3.5 boss room should be at least two spaces away from entrance
#4. Rooms select their layout randomly, based on doors and type of room
# 5. generate mini-map from this?
# 6. spawn player
