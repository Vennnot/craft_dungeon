extends ItemController

@export var cooldown : float = 1
@export var damage : int = 1
@onready var cooldown_timer: Timer = %CooldownTimer

var instantiated_item_scene : Node2D


func _ready() -> void:
	_initialize_item()
	cooldown_timer.wait_time = cooldown
	cooldown_timer.timeout.connect(_on_timer_timeout)
	spawn_item()
	cooldown_timer.start()


func _on_timer_timeout() -> void:
	instantiated_item_scene.enable_hitbox()
	cooldown_timer.start()


func spawn_item() -> void:
	var player : Player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	
	instantiated_item_scene = item_scene.instantiate() as Node2D
	player.add_child(instantiated_item_scene)
	instantiated_item_scene.set_damage(damage)
	instantiated_item_scene.global_position = player.global_position


func clear_children() -> void:
	instantiated_item_scene.call_deferred("queue_free")
	call_deferred("queue_free")
