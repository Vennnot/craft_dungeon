extends Node
class_name HealthComponent

signal died

@export_range(1,1000000) var max_health : int = 100
var current_health :
	set(value):
		if value < 0:
			value = 0
		current_health = value

func _ready() -> void:
	current_health = max_health


func get_damaged(damage:int):
	current_health -= damage
	if current_health == 0:
		die()
	print("Got damaged for %s" % damage)


func die() -> void:
	died.emit()
	owner.call_deferred("queue_free")
