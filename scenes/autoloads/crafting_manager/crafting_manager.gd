extends Node

var recipes : Array[Recipe] = [preload("res://resources/recipes/test_recipe.tres")]

func get_resource(ingredients:Array[Resource]) -> Resource:
	for recipe in recipes:
		if recipe.ingredients_list == ingredients:
			return recipe.result_item
	return null
