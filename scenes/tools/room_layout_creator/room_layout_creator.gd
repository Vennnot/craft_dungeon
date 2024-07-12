extends Node2D

var room_1 : bool
var room_2 : bool
var room_3 : bool
var room_4 : bool

var cell_size : int = 16
var _outline_color := Color(1, 0, 0)
var _highlight_pos : Vector2 = Vector2.ZERO
var exits : Dictionary = {}

const room_1_size :=  Vector2(9,9)
const room_2_size :=  Vector2(18,9)
const room_3_size :=  Vector2(18,18)
const room_4_size :=  Vector2(18,18)


@onready var room_select_button: OptionButton = %RoomSelectButton
@onready var exit_cells: Control = %ExitCells
@onready var room_cells: Control = %RoomCells


var cell_button_scene : PackedScene = preload("res://scenes/tools/cell_layout_button/cell_layout_button.tscn")
# select what cell to place down and see how much space it takes
# save and load layouts
# position cells and save their position + what they are supposed to be
# mark exits
# room expands selection to be able to disable a particular exit
# connect disabling to the actual room


func _ready():
	room_select_button.item_selected.connect(_on_room_selected)


func _process(_delta: float) -> void:
	queue_redraw()

func _draw():
	if room_1:
		draw_rect(Rect2(-(room_1_size*cell_size/2), room_1_size*cell_size), _outline_color, false,2)
	elif room_2:
		draw_rect(Rect2(-(room_2_size*cell_size/2), room_2_size*cell_size), _outline_color, false,2)
	elif room_3:
		_draw_l_shape()
	elif room_4:
		draw_rect(Rect2(-(room_4_size*cell_size/2), room_4_size*cell_size), _outline_color, false,2)


func _update_highlight(mouse_pos):
	if not room_1:
		mouse_pos.x -= 8
	if room_3 or room_4:
		mouse_pos.y -= 8
	_highlight_pos = mouse_pos.snapped(Vector2(cell_size, cell_size))
	queue_redraw()

func _draw_l_shape() -> void:
	var l_shape := room_3_size*cell_size
	draw_line(-(l_shape/2), Vector2(l_shape.x/2,-(l_shape.y/2)), _outline_color, 2)
	draw_line(Vector2(l_shape.x/2,-(l_shape.y/2)), Vector2(l_shape.x/2,l_shape.y/2), _outline_color, 2)
	draw_line(Vector2(l_shape.x/2,l_shape.y/2), Vector2(0,l_shape.y/2), _outline_color, 2)
	draw_line(Vector2(0,l_shape.y/2), Vector2.ZERO, _outline_color, 2)
	draw_line(Vector2.ZERO, Vector2(-l_shape.x/2,0), _outline_color, 2)
	draw_line(Vector2(-l_shape.x/2,0), -(l_shape/2), _outline_color, 2)


func _on_room_selected(active_room:int) -> void:
	match active_room:
		0:
			room_1 = true
		1:
			room_2 = true
		2:
			room_3 = true
		3:
			room_4 = true
	active_room += 1
	if active_room != 1:
		room_1 = false
	if active_room != 2:
		room_2 = false
	if active_room != 3:
		room_3 = false
	if active_room != 4:
		room_4 = false
	queue_redraw()
	_clear_current_room()
	_clear_current_exits()
	_initialize_exits(active_room)
	_create_room()


func _initialize_exits(active_room:int) -> void:
	exits = {}
	for exit in RoomShape.room_exits[active_room]:
		exits[exit] = "available"
	_create_exits()


func _create_room() -> void:
	if room_1:
		_create_room_1()
	elif room_2:
		_create_room_2()
	elif room_3:
		_create_room_3()
	elif room_4:
		_create_room_4()


func _create_room_1() -> void:
	for i in room_1_size.x:
		for j in room_1_size.y:
			var cell_button_instance := _instantiate_cell(false)
			cell_button_instance.vector_location = Vector2(i,j)
			_place_cell(Vector2((i-room_1_size.x/2)*cell_size,(j-room_1_size.y/2)*cell_size),cell_button_instance)


func _create_room_2() -> void:
	for i in room_2_size.x:
		for j in room_2_size.y:
			var cell_button_instance := _instantiate_cell(false)
			cell_button_instance.vector_location = Vector2(i,j)
			_place_cell(Vector2((i-room_2_size.x/2)*cell_size,(j-room_2_size.y/2)*cell_size),cell_button_instance)

func _create_room_3() -> void:
	for i in room_3_size.x:
		for j in room_3_size.y:
			if i <= 8 and j >= 9:
				continue
			var cell_button_instance := _instantiate_cell(false)
			cell_button_instance.vector_location = Vector2(i,j)
			_place_cell(Vector2((i-room_3_size.x/2)*cell_size,(j-room_3_size.y/2)*cell_size),cell_button_instance)

func _create_room_4() -> void:
	for i in room_4_size.x:
		for j in room_4_size.y:
			var cell_button_instance := _instantiate_cell(false)
			cell_button_instance.vector_location = Vector2(i,j)
			_place_cell(Vector2((i-room_4_size.x/2)*cell_size,(j-room_4_size.y/2)*cell_size),cell_button_instance)

func _create_exits() -> void:
	if room_1:
		_create_exits_room_1()
	elif room_2:
		_create_exits_room_2()
	elif room_3:
		_create_exits_room_3()
	elif room_4:
		_create_exits_room_4()

func _create_exits_room_1() -> void:
	#north and south
	_place_cell(Vector2(-cell_size/2,(-room_1_size.y*cell_size/2)-cell_size), _instantiate_cell(true,0))
	_place_cell(Vector2(-cell_size/2,room_1_size.y*cell_size/2), _instantiate_cell(true,2))
	
	#east and west
	_place_cell(Vector2(room_1_size.x*cell_size/2,(-cell_size/2)), _instantiate_cell(true,1))
	_place_cell(Vector2(-(room_1_size.x+2)*cell_size/2,(-cell_size/2)), _instantiate_cell(true,3))

func _create_exits_room_2() -> void:
	#north and south
	_place_cell(Vector2(-cell_size*10/2,(-room_2_size.y*cell_size/2)-cell_size), _instantiate_cell(true,0))
	_place_cell(Vector2(cell_size*10/2,room_2_size.y*cell_size/2), _instantiate_cell(true,3))
	
	_place_cell(Vector2(cell_size*10/2,(-room_2_size.y*cell_size/2)-cell_size), _instantiate_cell(true,1))
	_place_cell(Vector2(-cell_size*10/2,room_2_size.y*cell_size/2), _instantiate_cell(true,4))
	
	#east and west
	_place_cell(Vector2(room_2_size.x*cell_size/2,(-cell_size/2)), _instantiate_cell(true,2))
	_place_cell(Vector2(-(room_2_size.x+2)*cell_size/2,(-cell_size/2)), _instantiate_cell(true,5))

func _create_exits_room_3() -> void:
		#north and south
	_place_cell(Vector2(-cell_size*8/2,(-room_3_size.y*cell_size/2)-cell_size), _instantiate_cell(true,0))
	_place_cell(Vector2(cell_size*8/2,room_3_size.y*cell_size/2), _instantiate_cell(true,4))
	
	_place_cell(Vector2(cell_size*8/2,(-room_3_size.y*cell_size/2)-cell_size), _instantiate_cell(true,1))
	_place_cell(Vector2(-cell_size,(cell_size*8/2)), _instantiate_cell(true,5))
	
	#east and west
	_place_cell(Vector2(room_3_size.x*cell_size/2,(cell_size*8/2)), _instantiate_cell(true,3))
	_place_cell(Vector2((-cell_size*8/2),0), _instantiate_cell(true,6))
	
	_place_cell(Vector2(room_3_size.x*cell_size/2,(-cell_size*8/2)), _instantiate_cell(true,2))
	_place_cell(Vector2(-(room_3_size.x+2)*cell_size/2,(-cell_size*8/2)), _instantiate_cell(true,7))

func _create_exits_room_4() -> void:
	#north and south
	_place_cell(Vector2(-cell_size*8/2,(-room_4_size.y*cell_size/2)-cell_size), _instantiate_cell(true,0))
	_place_cell(Vector2(cell_size*8/2,room_4_size.y*cell_size/2), _instantiate_cell(true,4))
	
	_place_cell(Vector2(cell_size*8/2,(-room_4_size.y*cell_size/2)-cell_size), _instantiate_cell(true,1))
	_place_cell(Vector2(-cell_size*8/2,room_4_size.y*cell_size/2), _instantiate_cell(true,5))
	
	#east and west
	_place_cell(Vector2(room_4_size.x*cell_size/2,(cell_size*8/2)), _instantiate_cell(true,3))
	_place_cell(Vector2(-(room_4_size.x+2)*cell_size/2,(cell_size*8/2)), _instantiate_cell(true,6))
	
	_place_cell(Vector2(room_4_size.x*cell_size/2,(-cell_size*8/2)), _instantiate_cell(true,2))
	_place_cell(Vector2(-(room_4_size.x+2)*cell_size/2,(-cell_size*8/2)), _instantiate_cell(true,7))


func _instantiate_cell(exit:bool, id=-1) -> CellButton:
	var cell_button_instance : CellButton = cell_button_scene.instantiate()
	if exit:
		exit_cells.add_child(cell_button_instance)
	else:
		room_cells.add_child(cell_button_instance)
	if id != -1:
		cell_button_instance.id = id
	return cell_button_instance


func _place_cell(pos:Vector2,cell:CellButton) -> void:
	cell.position = pos


func _clear_current_exits() -> void:
	for child in exit_cells.get_children():
		child.queue_free()

func _clear_current_room() -> void:
	for child in room_cells.get_children():
		child.queue_free()
