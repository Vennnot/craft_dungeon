class_name RoomShape

var shape: Array[Vector2]  # Current cells occupied by the room
var exits: Array[Vector2]  # Exits relative to the room's position
var rotation: float = 0 # Current rotation angle
var flip_h: bool = false # Flipped on the H axis
var room_type : ROOM_TYPE
enum ROOM_TYPE {ONE=1,TWO=2,THREE=3,FOUR=4}

func _init(type:String)-> void:
	match type:
		"1":
			shape.assign(room_shapes["1"])
			exits.assign(room_exits["1"])
			room_type = ROOM_TYPE.ONE
		"2":
			shape.assign(room_shapes["2"])
			exits.assign(room_exits["2"])
			room_type = ROOM_TYPE.TWO
		"3":
			shape.assign(room_shapes["3"])
			exits.assign(room_exits["3"])
			room_type = ROOM_TYPE.THREE
		"4":
			shape.assign(room_shapes["4"])
			exits.assign(room_exits["4"])
			room_type = ROOM_TYPE.FOUR

# Apply a rotation to the room
func rotate(degrees: float) -> void:
	rotation += degrees
	rotation = fmod(rotation, 360)
	
	var rotated_shape :Array[Vector2]= []
	for c in shape:
		rotated_shape.append(rotate_vector(c, degrees))
		shape = rotated_shape
	
	var rotated_exits :Array[Vector2]= []
	for e in exits:
		rotated_exits.append(rotate_vector(e, degrees))
		exits = rotated_exits

	# Apply a flip to the room
func flip(horizontal: bool)->void:
	if not horizontal:
		return
	
	if not room_type == ROOM_TYPE.THREE:
		return
	
	flip_h = not flip_h
	
	var flipped_shape :Array[Vector2]= []
	for c in shape:
		flipped_shape.append(flip_vector_horizontally(c))
	shape = flipped_shape
	
	var flipped_exits :Array[Vector2]= []
	for e in exits:
		flipped_exits.append(flip_vector_horizontally(e))
	exits = flipped_exits


func flip_vector_horizontally(v: Vector2) -> Vector2:
	return Vector2(v.x * -1, v.y)

func rotate_vector(v: Vector2, degrees: float) -> Vector2:
	var radians = deg_to_rad(degrees)
	return Vector2(
		round(v.x * cos(radians) - v.y * sin(radians)),
		round(v.x * sin(radians) + v.y * cos(radians))
	)


#Translate the room to a new position
func move_to(position: Vector2) -> Array[Vector2]:
	var moved_shape :Array[Vector2]= []
	for cell in shape:
		moved_shape.append(position + cell)
	return moved_shape

# Define basic shapes
var room_shapes = {
	"1": [
		Vector2(0, 0)
	],
	"4": [
		Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)
	],
	"2": [
		Vector2(0, 0), Vector2(1, 0)
	],
	"3": [
		Vector2(0, 0), Vector2(1, 0), Vector2(1, 1)
	]
}

var room_exits = {
	"1": [
		Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)
	],
	"4": [
		Vector2(-1, 0), Vector2(-1, 1), Vector2(0, -1), Vector2(1, -1),
		Vector2(2, 0), Vector2(2, 1), Vector2(1, 2), Vector2(0, 2)
	],
	"2": [
		Vector2(-1, 0), Vector2(0, -1), Vector2(1, -1),
		Vector2(2, 0), Vector2(1, 1), Vector2(0, 1)
	],
	"3": [
		Vector2(-1, 0), Vector2(0, -1), Vector2(1, -1),
		Vector2(2, 0), Vector2(2, 1), Vector2(1, 2), Vector2(0, 1)
	]
}
