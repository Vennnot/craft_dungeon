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

var last_placed_room : Vector2

enum ROOM_TYPE {ONE,TWO,THREE,FOUR}

@onready var room_1: Node2D = %room1
@onready var room_2: Node2D = %room2
@onready var room_3: Node2D = %room3
@onready var room_4: Node2D = %room4

func _ready() -> void:
	_initialize_number_of_rooms()
	_initialize_grid()
	_generate_spawn_room()
	_generate_base_rooms()


func _initialize_grid() -> void:
	var modifier := floor_modifier*5
	for i in modifier:
		var row := []
		for j in modifier:
			row.append(0)
		dungeon_grid.append(row)


#TODO spawn the room
func _generate_spawn_room() -> void:
	@warning_ignore("integer_division")
	var base_number : Vector2 = Vector2(floor_modifier*5/2,floor_modifier*5/2)
	base_number.x += (randi_range(-floor_modifier,floor_modifier))
	base_number.y += (randi_range(-floor_modifier,floor_modifier))
	dungeon_grid[base_number.x][base_number.y] = 1
	last_placed_room = dungeon_grid[base_number.x][base_number.y]



func _generate_base_rooms() -> void:
	_initialize_room_chance_variables()
	while number_of_rooms > 0:
		var room_to_generate := _get_random_room_type()
		print(room_to_generate)
		#TODO connect previous room to current room
		#TODO update grid
		number_of_rooms -= 1
	
	
	


func _initialize_room_chance_variables() -> void:
	double_room_chance = base_double_room_chance
	triple_room_chance = base_triple_room_chance
	quadruple_room_chance = base_quadruple_room_chance


func _get_random_room_type() -> Node2D:
	randomize()
	var random_float := randf_range(0,1)
	if random_float < quadruple_room_chance:
		#FIXME this random ass decrease
		quadruple_room_chance /= (8-float(floor_modifier))
		return room_4
	elif random_float < quadruple_room_chance + triple_room_chance:
		triple_room_chance /= (8-float(floor_modifier)/2)
		return room_3
	elif random_float < quadruple_room_chance + triple_room_chance + double_room_chance:
		double_room_chance /= (8-float(floor_modifier)/4)
		return room_2
	else:
		return room_1


func _initialize_number_of_rooms() -> void:
	number_of_rooms = 4 + (floor_modifier * 2) + randi_range(0,2)


func _get_empty_adjacent_cells() -> Array[Vector2]:
	var empty_adjacent_cells := []
	if dungeon_grid[last_placed_room.x+1][last_placed_room.y] == 0:
		empty_adjacent_cells.append(Vector2(last_placed_room.x+1,last_placed_room.y))
	elif dungeon_grid[last_placed_room.x-1][last_placed_room.y] == 0:
		empty_adjacent_cells.append(Vector2(last_placed_room.x-1,last_placed_room.y))
	elif dungeon_grid[last_placed_room.x][last_placed_room.y+1] == 0:
		empty_adjacent_cells.append(Vector2(last_placed_room.x,last_placed_room.y+1))
	elif dungeon_grid[last_placed_room.x+1][last_placed_room.y-1] == 0:
		empty_adjacent_cells.append(Vector2(last_placed_room.x,last_placed_room.y-1))
	return empty_adjacent_cells

func _get_fitting_room_orientation() -> void:
	pass

# generate rooms on a grid
# 1. Can choose from multiple rooms, repetition and frequency depends on floor difficulty
# 2. Connects room as they are placed. Connections are chosen at random.
# 2.5 All rooms that have more than one neighbor should have two connections each
# 3. Once complete place special rooms. They only have one entrance to a non-special room.
# 3.5 boss room should be at least two spaces away from entrance
#4. Rooms select their layout randomly, based on doors and type of room
# 5. generate mini-map from this?
# 6. spawn player
