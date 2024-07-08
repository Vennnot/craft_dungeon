@tool
extends Node2D

@export var room_1 : bool :
	set(value):
		_reset_other_areas()
		room_1 = value
@export var room_2 : bool :
	set(value):
		_reset_other_areas()
		room_1 = value
@export var room_3 : bool :
	set(value):
		_reset_other_areas()
		room_1 = value
@export var room_4 : bool :
	set(value):
		_reset_other_areas()
		room_1 = value

var cell_size :int=16
var _outline_color := Color(1, 0, 0)
var _area_size := Vector2(100, 100)

func _draw():
	if room_1:
		draw_rect(Rect2(Vector2(10, 10), _area_size), _outline_color, false)
	elif room_2:
		draw_rect(Rect2(Vector2(150, 10), _area_size), _outline_color, false)
	elif room_3:
		draw_rect(Rect2(Vector2(10, 150), _area_size), _outline_color, false)
	elif room_4:
		draw_rect(Rect2(Vector2(150, 150), _area_size), _outline_color, false)


func _reset_other_areas():
	room_1 = false
	room_2 = false
	room_3 = false
	room_4 = false
