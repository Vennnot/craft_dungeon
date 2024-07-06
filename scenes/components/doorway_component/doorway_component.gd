extends StaticBody2D
class_name DoorwayComponent

signal active_room(room:Room)

@onready var teleport_marker : Marker2D = %Marker2D
@onready var sprite: Sprite2D = %Sprite2D
@onready var area: Area2D = %Area2D


@export var other_doorway : DoorwayComponent :
	set(value):
		other_doorway = value
		if value != null:
			sprite.visible = true
		else:
			print("Connecting to a null value!!!")

@export var doorway_room_vector : Vector2 =  Vector2.ZERO

var is_locked : bool = false
var is_hidden : bool = false
var is_disabled : bool = false


# doorway value needs to change when it rotates
func _ready() -> void:
	area.area_entered.connect(_on_area_entered)


func enable() -> void:
	is_disabled = false



func _on_area_entered(other_area:Area2D) -> void:
	if is_disabled:
		return
	
	if other_doorway == null:
		return
	
	if is_locked:
		return
	
	
	if other_area.get_parent().get_parent() == null:
		return
	
	if not other_area.get_parent().is_in_group("player"):
		return
	
	if not other_area.is_in_group("hurtbox_component"):
		return
	
	var player : Player = other_area.get_parent()
	player.call_deferred("teleport",other_doorway.teleport_marker.global_position)
	other_doorway.active_room.emit()


func rotate_vector(degrees: float) -> void:
	var radians = deg_to_rad(degrees)
	doorway_room_vector = Vector2(
		round(doorway_room_vector.x * cos(radians) - doorway_room_vector.y * sin(radians)),
		round(doorway_room_vector.x * sin(radians) + doorway_room_vector.y * cos(radians))
	)


func flip_vector_horizontally(flip:bool) -> void:
	if not flip:
		return
	doorway_room_vector = Vector2(doorway_room_vector.x * -1, doorway_room_vector.y)
