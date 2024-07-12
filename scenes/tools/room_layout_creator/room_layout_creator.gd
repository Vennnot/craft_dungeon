extends Node2D

var room_1 : bool
var room_2 : bool
var room_3 : bool
var room_4 : bool

var difficulty : int = 0
var room_type : int = 0
var exits : Dictionary = {}
var cells : Dictionary = {}

var cell_size : int = 16
var _outline_color := Color(1, 0, 0)
var _highlight_pos : Vector2 = Vector2.ZERO
var selected_button : CellButton

const room_1_size :=  Vector2(9,9)
const room_2_size :=  Vector2(18,9)
const room_3_size :=  Vector2(18,18)
const room_4_size :=  Vector2(18,18)


@onready var room_select_button: OptionButton = %RoomSelectButton
@onready var difficulty_select_button: OptionButton = %DifficultySelectButton
@onready var special_room_select_button: OptionButton = %SpecialRoomSelectButton


@onready var exit_cells: Control = %ExitCells
@onready var room_cells: Control = %RoomCells
@onready var options_container: VBoxContainer = %OptionsContainer
@onready var cell_clear_button: Button = %CellClearButton
@onready var save_button: Button = %SaveButton


var cell_button_scene : PackedScene = preload("res://scenes/tools/cell_layout_button/cell_layout_button.tscn")
var current_layout : RoomLayout

func _ready():
	room_select_button.item_selected.connect(_on_room_selected)
	cell_clear_button.pressed.connect(_on_clear_options_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)


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


func _on_button_selected(cell_button:CellButton)->void:
	_unhighlight_button()
	selected_button = cell_button
	selected_button.modulate = Color.GREEN_YELLOW
	_update_options()


func _update_options()->void:
	_clear_options_buttons()
	if selected_button == null:
		return
	
	if selected_button.type != CellButton.TYPE.NONE:
		pass
		#TODO add specific options for that type of button
	
	else:
		for i in CellButton.TYPE:
			if i == "NONE":
				continue
			var button_to_add : Button = Button.new()
			options_container.add_child(button_to_add)
			var x : String = i
			button_to_add.pressed.connect(_set_button_type.bind(x))
			button_to_add.text = i


func _unhighlight_button()->void:
	if selected_button != null:
		selected_button.modulate = Color.WHITE


func _clear_selection() -> void:
	_clear_options_buttons()
	_unhighlight_button()
	selected_button = null


func _clear_options_buttons() -> void:
	for child in options_container.get_children():
		child.queue_free()


func _instantiate_cell(exit:bool, id=-1) -> CellButton:
	var cell_button_instance : CellButton = cell_button_scene.instantiate()
	if exit:
		exit_cells.add_child(cell_button_instance)
	else:
		room_cells.add_child(cell_button_instance)
	if id != -1:
		cell_button_instance.id = id
	cell_button_instance.selected.connect(_on_button_selected)
	return cell_button_instance


func _place_cell(pos:Vector2,cell:CellButton) -> void:
	cell.position = pos


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
	_clear_selection()
	_create_exits()
	_create_room()


func _initialize_exits_dictionary() -> void:
	exits = {}
	for exit in exit_cells.get_children():
		exits[exit.id] = true


func _update_exits_dictionary(id:int)->void:
	exits[id] = selected_button.is_exit_locked


func _update_cells_dictionary()->void:
	if selected_button.type == CellButton.TYPE.NONE:
		if cells[selected_button.vector_location]:
			cells.erase(selected_button.vector_location)
			return


func _create_room() -> void:
	if room_1:
		_create_room_1()
	elif room_2:
		_create_room_2()
	elif room_3:
		_create_room_3()
	elif room_4:
		_create_room_4()
	cells = {}


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
	_initialize_exits_dictionary()


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


func _clear_current_exits() -> void:
	for child in exit_cells.get_children():
		child.queue_free()


func _clear_current_room() -> void:
	for child in room_cells.get_children():
		child.queue_free()


func _on_clear_options_button_pressed() -> void:
	selected_button.reset()
	_update_options()


func _set_button_type(type:String)->void:
	selected_button.set_type(type)
	_update_options()


func _on_save_button_pressed()->void:
	var room_layout : RoomLayout = _create_room_layout()
	if current_layout != null:
		var file_path : String = current_layout.get_path()
		ResourceSaver.save(room_layout,file_path)
		current_layout = room_layout
	else:
		pass


func _create_room_layout()->RoomLayout:
	var room_layout : RoomLayout = RoomLayout.new()
	room_layout.difficulty = difficulty
	room_layout.type = room_type
	room_layout.exits = exits
	room_layout.cells = cells
	return room_layout
