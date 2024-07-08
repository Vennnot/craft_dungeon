@tool
extends Node2D

@export var room_1 : bool :
	set(value):
		if value:
			_reset_other_areas("1")
		room_1 = value
@export var room_2 : bool :
	set(value):
		if value:
			_reset_other_areas("2")
		room_2 = value
@export var room_3 : bool :
	set(value):
		if value:
			_reset_other_areas("3")
		room_3 = value
@export var room_4 : bool :
	set(value):
		if value:
			_reset_other_areas("4")
		room_4 = value

var cell_size : int = 16
var _outline_color := Color(1, 0, 0)
var _highlight_pos : Vector2 = Vector2.ZERO

const room_1_size :=  Vector2(9,9)
const room_2_size :=  Vector2(18,9)
const room_3_size :=  Vector2(18,18)
const room_4_size :=  Vector2(18,18)


func _ready():
	set_process(true)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_update_highlight(get_viewport().get_mouse_position())



func _draw():
	if room_1:
		draw_rect(Rect2(-(room_1_size*cell_size/2), room_1_size*cell_size), _outline_color, false,2)
	elif room_2:
		draw_rect(Rect2(-(room_2_size*cell_size/2), room_2_size*cell_size), _outline_color, false,2)
	elif room_3:
		_draw_l_shape()
	elif room_4:
		draw_rect(Rect2(-(room_4_size*cell_size/2), room_4_size*cell_size), _outline_color, false,2)
	_draw_highlight()


func _draw_highlight():
	var half_size = Vector2(cell_size, cell_size) / 2
	var adjusted_pos = _highlight_pos
	
	# Adjust position based on room conditions
	if not room_1:
		adjusted_pos.x += 8
	if room_3 or room_4:
		adjusted_pos.y += 8
	
	draw_rect(Rect2(adjusted_pos - half_size, Vector2(cell_size, cell_size)), Color(1, 1, 0, 0.5), true)



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

func _reset_other_areas(active_room:String) -> void:
	if active_room != "1":
		room_1 = false
	if active_room != "2":
		room_2 = false
	if active_room != "3":
		room_3 = false
	if active_room != "4":
		room_4 = false
	queue_redraw()
