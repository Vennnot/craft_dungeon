extends Resource
class_name Item

signal cooldown_changed(value)

@export var id : StringName
@export var name : String
@export var controller_scene : PackedScene
@export var is_passive : bool
@export var texture : Texture
@export var cooldown : float
var current_cooldown_percent : float :
	set(value):
		current_cooldown_percent = value
		cooldown_changed.emit(current_cooldown_percent)
