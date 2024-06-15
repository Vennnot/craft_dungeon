extends Node

@export var test_item : PackedScene

@onready var timer: Timer = %Timer

@export var cooldown : float = 1.5

func _ready() -> void:
	timer.wait_time = cooldown
