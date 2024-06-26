extends Node2D
class_name Room

var room_shape : RoomShape

var dungeon_grid_position : Vector2

var doorways_array : Array[DoorwayComponent]
# 1 means they are connected
var exit_connections : Dictionary = {}


@onready var camera_collision: Area2D = $CameraCollisionAreaComponent
@onready var tile_map: TileMap = %TileMap
@onready var doorways: Node2D = %Doorways


var doorway_tile_layer : int = 0

func _ready() -> void:
	_initialize_doorways()


func _initialize_doorways() -> void:
	for doorway in doorways.get_children():
		doorways_array.append(doorway)
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
	set_rotation(deg_to_rad(room_shape.rotation))
	set_flipped(room_shape.flip_h)


func _load_debug_shapes() -> void:
	var color : Color
	
	match room_shape.room_type:
		0:
			color = Color.RED
		1:
			color = Color.YELLOW
		2:
			color = Color.PURPLE
		3:
			color = Color.GREEN
	
	#TODO exit visuals
	for cell in room_shape.shape:
		var sprite := Sprite2D.new()
		add_child(sprite)
		sprite.global_position = position + cell*32
		sprite.texture = load("res://icon.svg")
		sprite.scale = Vector2(0.25,0.25)
		sprite.self_modulate = color

func set_room_position(pos:Vector2) -> void:
	position.x = pos.x
	position.y = pos.y
	_load_debug_shapes()
	for exit in get_exits():
		exit_connections[exit] = Vector2.ZERO
	print(exit_connections)
	print(get_cells())


func set_dungeon_grid_position(grid_pos:Vector2) -> void:
	dungeon_grid_position = grid_pos


func set_flipped(flip_h:bool) -> void:
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


func is_exit_connected(exit:Vector2) -> bool:
	return exit_connections[exit] != Vector2.ZERO


func has_cell(cell:Vector2) -> bool:
	return get_cells().has(cell)
