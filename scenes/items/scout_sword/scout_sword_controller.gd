extends ItemController

@export var cooldown : float = 10
@export var damage : int = 5
@onready var cooldown_timer: Timer = %CooldownTimer
var cooldown_percent : float :
	set(value):
		if cooldown_percent != value:
			cooldown_percent = value
			if item != null:
				item.current_cooldown_percent = value

func _ready() -> void:
	_initialize_item()
	print(item)
	cooldown_timer.wait_time = cooldown
	cooldown_timer.timeout.connect(_on_timer_timeout)


func use() -> void:
	if not cooldown_timer.is_stopped():
		return
	
	spawn_item()
	cooldown_timer.start()

func _process(_delta: float) -> void:
	if not cooldown_timer.is_stopped():
		var percent : float = cooldown_timer.time_left / cooldown
		cooldown_percent = (round(percent*100)/100)


func _on_timer_timeout() -> void:
	pass

func spawn_item() -> void:
	var player : Player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	
	var scout_sword_instance := item_scene.instantiate() as Node2D
	player.get_parent().add_child(scout_sword_instance)
	scout_sword_instance.set_damage(damage)
	scout_sword_instance.global_position = player.global_position
	scout_sword_instance.global_position += get_parent().get_look_direction()*25
	scout_sword_instance.rotation = rad_to_deg(get_parent().get_look_direction().angle())
