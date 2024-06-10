extends Node

var recipes : Array[Recipe] = [preload("res://resources/recipes/test_recipe.tres")]

func get_resource(ingredients:Array[Resource]) -> Resource:
	for recipe in recipes:
		if _compare_recipe_to_ingredients(ingredients,recipe):
			return recipe.result_item
	return null


func _compare_recipe_to_ingredients(ingredients:Array[Resource], recipe:Recipe) -> bool:
	var array_one := ingredients.filter(_null_filter)
	var array_two := recipe.ingredients_list.filter(_null_filter)
	array_one.sort()
	array_two.sort()
	return array_one == array_two


func _null_filter(element:Variant) -> bool:
	return element != null