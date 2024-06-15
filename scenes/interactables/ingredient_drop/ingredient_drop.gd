extends Node2D
class_name IngredientDrop

@export var ingredient:Resource

func _ready() -> void:
	$PickupArea.area_entered.connect(_on_area_entered)


func _on_area_entered(other_area:Area2D)->void:
	if other_area.get_parent() is Player:
		InventoryManager.add_resource(ingredient)
		queue_free()


func set_ingredient(new_ingredient:Resource)-> void:
	ingredient = new_ingredient
	if ingredient != null:
		$Sprite2D.texture = ingredient.texture
