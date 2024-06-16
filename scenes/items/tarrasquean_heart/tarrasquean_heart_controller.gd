extends ItemController

@export var cooldown : float = 1
@export var heal_amount : int = 1
@onready var cooldown_timer: Timer = %CooldownTimer

var health_component : HealthComponent


func _ready() -> void:
	_initialize_item()
	_initialize_health_component()
	cooldown_timer.wait_time = cooldown
	cooldown_timer.timeout.connect(_on_timer_timeout)
	cooldown_timer.start()


func _on_timer_timeout() -> void:
	health_component.heal(heal_amount)
	cooldown_timer.start()


func clear_children() -> void:
	call_deferred("queue_free")

func _initialize_health_component() -> void:
	health_component = get_tree().get_first_node_in_group("player").health_component
	
