extends Node

@onready var phantom_camera: PhantomCamera2D = %PhantomCamera2D

func set_follow_target(player:Player) -> void:
	phantom_camera.set_follow_target(player)


func set_limit_target(node_path:String) -> void:
	phantom_camera.set_limit_target(node_path)


# TODO when moving to a new room animate moving to that room and stop
