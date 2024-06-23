extends Area2D
class_name DoorwayComponent

signal active_room(room:Room)

@export var teleport_marker : Marker2D

@export var other_doorway : DoorwayComponent

var is_locked : bool = false


func _ready() -> void:
	assert(teleport_marker!=null,"Doorway teleport_marker is empty!")
	area_entered.connect(_on_area_entered)


func _on_area_entered(other_area:Area2D) -> void:
	if other_doorway == null:
		return
	
	if is_locked:
		return
	
	
	if other_area.get_parent() == null:
		return
	
	if not other_area.get_parent().is_in_group("player"):
		return
	
	var player : Player = other_area.get_parent()
	player.teleport(other_doorway.teleport_marker.global_position)
	other_doorway.active_room.emit()
