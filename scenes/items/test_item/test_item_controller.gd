extends Node

var test_item : PackedScene = preload("res://scenes/items/test_item/test_item.tscn")
var item : Item

@export var item_id : StringName
@export var cooldown : float = 1.5

@onready var timer: Timer = %Timer

func _ready() -> void:
	item = CraftingManager.get_item_by_id(item_id)
	timer.wait_time = cooldown
	timer.start()
	timer.timeout.connect(_on_timer_timeout)


func _process(_delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	print("spawn scene")
	timer.start()
