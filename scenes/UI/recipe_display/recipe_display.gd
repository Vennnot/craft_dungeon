extends Button
class_name RecipeDisplay

@onready var result_box : ResourceBox = %ResourceBox1

var ingredients : Array[ResourceBox] = []
var recipe : Recipe = null


func _ready() -> void:
	_initialize_children()


func set_recipe(new_recipe:Recipe) -> void:
	recipe = new_recipe
	result_box.set_texture(new_recipe.result_item.texture)
	
	for i in recipe.ingredients_list.size():
		if recipe.ingredients_list[i-1]:
			ingredients[i-1].set_texture(recipe.ingredients_list[i-1].texture)


func get_recipe() -> Recipe:
	return recipe


func _initialize_children() -> void:
	ingredients.append(%ResourceBox2)
	ingredients.append(%ResourceBox3)
	ingredients.append(%ResourceBox4)
	ingredients.append(%ResourceBox5)
	ingredients.append(%ResourceBox6)

func _pressed() -> void:
	InventoryManager.emit_recipe_selected(recipe)
