extends Node

@export var all_recipes_group:ResourceGroup
@export var all_items_group:ResourceGroup
@export var all_crafting_materials_group:ResourceGroup

var all_recipes : Array[Recipe]
var all_items : Array[Item]
var all_crafting_materials : Array[CraftingMaterial]

func _ready() -> void:
	all_recipes_group.load_all_into(all_recipes)
	all_items_group.load_all_into(all_items)
	all_crafting_materials_group.load_all_into(all_crafting_materials)


func get_resource(ingredients:Array[Resource]) -> Resource:
	for recipe in all_recipes:
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


func get_item_by_id(id:StringName) -> Item:
	for item in all_items:
		if item.id == id:
			return item
	return null

func get_crafting_material_by_id(id:StringName) -> CraftingMaterial:
	for crafting_material in all_crafting_materials:
		if crafting_material.id == id:
			return crafting_material
	return null
