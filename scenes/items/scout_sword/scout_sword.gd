extends Node2D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var hitbox_component: HitboxComponent = %HitboxComponent


func _ready() -> void:
	animation_player.play("use")


func _complete() -> void:
	call_deferred("queue_free")


func set_damage(damage:int) -> void:
	hitbox_component.damage = damage
