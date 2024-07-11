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
	_initialize_exits(active_room)
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


func _initialize_exits(active_room:int) -> void:
	exits = {}
	print("called")
	for exit in RoomShape.room_exits[active_room+1]:
		exits[exit] = "available"
	print(exits)
