extends Node2D

@onready var hitbox_component: HitboxComponent = %HitboxComponent
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var timer: Timer = %Timer

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)

func enable_hitbox() -> void:
	collision_shape_2d.disabled = false
	timer.start()

func _on_timer_timeout() -> void:
	disable_hitbox()


func disable_hitbox() -> void:
	collision_shape_2d.disabled = true

func set_damage(damage:int) -> void:
	hitbox_component.damage = damage
