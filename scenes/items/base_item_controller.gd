extends Node
class_name ItemController

var item : Item
var disabled : bool = false
@export var item_scene : PackedScene
@export var item_id : StringName


func use() -> void:
	pass


func _initialize_item() -> void:
	item = CraftingManager.get_item_by_id(item_id)
