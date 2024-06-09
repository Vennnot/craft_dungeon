extends CharacterBody2D
class_name Player

@export_group("Movement","movement")
@export var movement_speed : float = 500
@export var movement_friction : float = 0.18

@onready var interaction_area: Area2D = $InteractionArea

var input_disabled : bool = false
var interaction_nodes : Array[Node] = []

func _ready() -> void:
	interaction_area.area_entered.connect(_on_interaction_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_exited)


func _process(_delta) -> void:
	var direction := _get_movement_direction()
	
	if input_disabled:
		direction = Vector2.ZERO
	
	var target_velocity = movement_speed*direction
	velocity += (target_velocity - velocity) * movement_friction
	
	move_and_slide()


func interact() -> void:
	pass


func _get_movement_direction() -> Vector2:
	var direction := Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
								Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))

	if direction.length() > 1.0:
		direction = direction.normalized()
		
	return direction


func _on_interaction_area_entered(other_area:Area2D) -> void:
	interaction_nodes.append(other_area.get_parent())

func _on_interaction_area_exited(other_area:Area2D) -> void:
	interaction_nodes.erase(other_area.get_parent())
