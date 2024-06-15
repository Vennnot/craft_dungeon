extends CharacterBody2D

@export var max_speed = 40

@onready var health_component : HealthComponent = %HealthComponent


func _process(_delta: float) -> void:
	var direction = get_direction_to_player()
	velocity = direction * max_speed
	move_and_slide()
	


func get_direction_to_player() -> Vector2:
	var player : Node = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player != null:
		return (player.global_position - global_position).normalized()
	return Vector2.ZERO
