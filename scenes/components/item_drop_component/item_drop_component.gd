extends Node

var ingredient_drop_scene : PackedScene = preload("res://scenes/interactables/ingredient_drop/ingredient_drop.tscn")
@export var crafting_material : CraftingMaterial
@export var health_component : HealthComponent

func _ready() -> void:
	health_component.died.connect(_on_death)


func _on_death() -> void:
	var ingredient_drop : IngredientDrop = ingredient_drop_scene.instantiate()
	ingredient_drop.global_position = get_parent().global_position
	#INFO calls deferred, otherwise flushing queries error
	get_tree().get_first_node_in_group("interactables").call_deferred("add_child",ingredient_drop)
	ingredient_drop.set_ingredient(crafting_material)
