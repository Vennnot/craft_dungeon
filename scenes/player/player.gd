extends CharacterBody2D

@export_group("Movement","movement")
@export var movement_speed : float = 500
@export var movement_friction : float = 0.18


func _process(_delta) -> void:
	
	
	var direction := _get_movement_direction()
	
	var target_velocity = movement_speed*direction
	velocity += (target_velocity - velocity) * movement_friction
	
	move_and_slide()

func _get_movement_direction() -> Vector2:
	var direction := Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
								Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))

	if direction.length() > 1.0:
		direction = direction.normalized()
		
	return direction
