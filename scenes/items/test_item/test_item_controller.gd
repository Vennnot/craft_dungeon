extends ItemController

@export var cooldown : float = 5
@onready var timer: Timer = %Timer

func _ready() -> void:
	_initialize_item()
	timer.wait_time = cooldown
	timer.start()
	timer.timeout.connect(_on_timer_timeout)


func use() -> void:
	print("used test item")

func _process(_delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	print("spawn scene")
	timer.start()
