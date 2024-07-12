extends Node2D

var room_1 : bool
var room_2 : bool
var room_3 : bool
var room_4 : bool

var difficulty : int = 0
var room_type : Room.TYPE = Room.TYPE.DEFAULT
var exits : Dictionary = {}
var cells : Dictionary = {}

var cell_size : int = 16
var _outline_color := Color(1, 0, 0)
var selected_cell : CellButton
var current_layout : RoomLayout

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
@onready var load_line_edit: LineEdit = %LoadLineEdit
@onready var load_button: Button = %LoadButton
@onready var clear_button: Button = %ClearButton


var cell_button_scene : PackedScene = preload("res://scenes/tools/cell_layout_button/cell_layout_button.tscn")

func _ready():
	room_select_button.item_selected.connect(_on_room_selected)
	difficulty_select_button.item_selected.connect(_on_difficulty_selected)
	special_room_select_button.item_selected.connect(_on_special_room_selected)
	cell_clear_button.pressed.connect(_on_clear_options_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)


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


func _draw_l_shape() -> void:
	var l_shape := room_3_size*cell_size
	draw_line(-(l_shape/2), Vector2(l_shape.x/2,-(l_shape.y/2)), _outline_color, 2)
	draw_line(Vector2(l_shape.x/2,-(l_shape.y/2)), Vector2(l_shape.x/2,l_shape.y/2), _outline_color, 2)
	draw_line(Vector2(l_shape.x/2,l_shape.y/2), Vector2(0,l_shape.y/2), _outline_color, 2)
	draw_line(Vector2(0,l_shape.y/2), Vector2.ZERO, _outline_color, 2)
	draw_line(Vector2.ZERO, Vector2(-l_shape.x/2,0), _outline_color, 2)
	draw_line(Vector2(-l_shape.x/2,0), -(l_shape/2), _outline_color, 2)


func _on_cell_selected(cell_button:CellButton)->void:
	_unhighlight_button()
	selected_cell = cell_button
	selected_cell.modulate = Color.GREEN_YELLOW
	_update_options()


func _update_options()->void:
	_clear_options_buttons()
	if selected_cell == null:
		return
	
	if selected_cell.type == CellButton.TYPE.EXIT:
		_create_exit_options()
	
	else:
		for i in CellButton.TYPE:
			if i == "NONE":
				continue
			if i == "EXIT":
				continue
			var button_to_add : Button = Button.new()
			options_container.add_child(button_to_add)
			var x : String = i
			button_to_add.pressed.connect(_set_button_type.bind(x))
			button_to_add.text = i

func _create_exit_options()->void:
	var button_to_add : CheckBox = CheckBox.new()
	options_container.add_child(button_to_add)
	button_to_add.button_pressed = selected_cell.is_exit_open
	button_to_add.toggled.connect(func(toggled_on:bool):
		selected_cell.is_exit_open = toggled_on)


func _unhighlight_button()->void:
	if selected_cell != null:
		selected_cell.modulate = Color.WHITE


func _clear_selection() -> void:
	_clear_options_buttons()
	_unhighlight_button()
	selected_cell = null


func _clear_options_buttons() -> void:
	for child in options_container.get_children():
		child.queue_free()


func _instantiate_cell(exit:bool, id=-1) -> CellButton:
	var cell_button_instance : CellButton = cell_button_scene.instantiate()
	if id != -1:
		cell_button_instance.id = id
	
	if exit:
		exit_cells.add_child(cell_button_instance)
		cell_button_instance.exit_changed.connect(_update_exits_dictionary)
	else:
		room_cells.add_child(cell_button_instance)
		cell_button_instance.type_changed.connect(_update_cells_dictionary)
	
	cell_button_instance.selected.connect(_on_cell_selected)
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


func _on_difficulty_selected(index:int) -> void:
	difficulty = index


func _on_special_room_selected(index:int) -> void:
	match index:
		0:
			room_type = Room.TYPE.DEFAULT
		1:
			room_type = Room.TYPE.BOSS
		2:
			room_type = Room.TYPE.ITEM
		3:
			room_type = Room.TYPE.CRAFTING
		4:
			room_type = Room.TYPE.SHOP


func _initialize_exits_dictionary() -> void:
	exits = {}
	for exit in exit_cells.get_children():
		exits[exit.id] = true


func _update_exits_dictionary(id:int)->void:
	if selected_cell == null:
		return
	exits[id] = selected_cell.is_exit_open


func _update_cells_dictionary(vector_location:Vector2)->void:
	if selected_cell.type == CellButton.TYPE.NONE:
		if cells[selected_cell.vector_location]:
			cells.erase(selected_cell.vector_location)
	
	elif selected_cell.type == CellButton.TYPE.ENEMY:
		cells[selected_cell.vector_location] = "enemy"
	
	
	elif selected_cell.type == CellButton.TYPE.ITEM:
		pass
	
	
	elif selected_cell.type == CellButton.TYPE.INTERACTABLE:
		pass


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
	selected_cell.reset()
	_update_options()


func _set_button_type(type:String)->void:
	selected_cell.set_type(type)
	_update_options()


func _on_save_button_pressed()->void:
	var room_layout : RoomLayout = _create_room_layout()
	var file_path := _get_file_path()
	room_layout.file_path = file_path
	ResourceSaver.save(room_layout,room_layout.file_path)
	current_layout = room_layout


func _create_room_layout()->RoomLayout:
	var room_layout : RoomLayout = RoomLayout.new()
	room_layout.difficulty = difficulty
	@warning_ignore("int_as_enum_without_cast")
	room_layout.type = room_type
	room_layout.exits = exits
	room_layout.cells = cells
	if room_1:
		room_layout.room = 0
	if room_2:
		room_layout.room = 1
	if room_3:
		room_layout.room = 2
	if room_4:
		room_layout.room = 3
	return room_layout


func _get_file_path()->String:
	var file_path : String = "res://resources/room_layouts/"
	if current_layout != null:
		file_path = current_layout.file_path
	else:
		file_path = _get_room_folder(file_path)
		if room_type == Room.TYPE.DEFAULT:
			file_path += "special/"
		else:
			file_path += "default/"
		file_path += _create_file_name(file_path)
	return file_path


func _create_file_name(file_path:String) -> String:
	var file_name : String = ""
	file_name += str(_get_file_count(file_path)).pad_zeros(4)
	if room_1:
		file_name += "_r1_"
	if room_2:
		file_name += "_r2_"
	if room_3:
		file_name += "_r3_"
	if room_4:
		file_name += "_r4_"
	
	match difficulty:
		0:
			file_name += "easy"
		1:
			file_name += "medium"
		2:
			file_name += "hard"
	
	match room_type:
		Room.TYPE.DEFAULT:
			pass
		Room.TYPE.BOSS:
			file_name += "_boss"
		Room.TYPE.ITEM:
			file_name += "_item"
		Room.TYPE.CRAFTING:
			file_name += "_crafting"
		Room.TYPE.SHOP:
			file_name += "_shop"
	
	file_name+=".tres"
	return file_name


func _get_room_folder(file_path:String)->String:
	if room_1:
		file_path += "room_1/"
	if room_2:
		file_path += "room_2/"
	if room_3:
		file_path += "room_3/"
	if room_4:
		file_path += "room_4/"
	return file_path


func _get_file_count(file_path:String)->int:
	var file_count = 0
	var dir = DirAccess.open(file_path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if dir.current_is_dir() == false:
				file_count += 1
			file_name = dir.get_next()
		
		dir.list_dir_end()
	else:
		print("Failed to open directory: ", file_path)
	
	return file_count


func _on_load_button_pressed()->void:
	var file_path : String = load_line_edit.text
	load_line_edit.text = ""
	current_layout = ResourceLoader.load(file_path)
	room_select_button.select(current_layout.room)
	room_select_button.item_selected.emit(current_layout.room)
	difficulty_select_button.select(current_layout.difficulty)
	difficulty_select_button.item_selected.emit(current_layout.room)
	special_room_select_button.select(int(current_layout.type))
	special_room_select_button.item_selected.emit(current_layout.room)
	
	exits = current_layout.exits
	for exit in exits.keys():
		for e in exit_cells.get_children():
			if exit == e.id:
				e.is_exit_open = exits[exit]
	
	#TODO update actual cells
	cells = current_layout.cells
