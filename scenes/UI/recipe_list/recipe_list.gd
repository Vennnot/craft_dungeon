extends VBoxContainer
class_name RecipeList

var recipe_display : PackedScene = preload("res://scenes/UI/recipe_display/recipe_display.tscn")

func _ready() -> void:
	_initialize_recipes()


func _initialize_recipes() -> void:
	for recipe in CraftingManager.recipes:
		var recipe_instance : RecipeDisplay = recipe_display.instantiate()
		add_child(recipe_instance)
		recipe_instance.set_recipe(recipe)
