extends Button
class_name RecipeDisplay

signal recipe_selected(recipe)

@onready var result_box : ResourceBox = %ResourceBox1

var ingredients : Array[ResourceBox] = []
var recipe : Recipe = null


func _ready() -> void:
	_initialize_children()


func set_recipe(new_recipe:Recipe) -> void:
	recipe = new_recipe
	result_box.set_display(new_recipe.result_item)
	
	for i in recipe.ingredients_list.size():
		ingredients[i-1].set_display(recipe.ingredients_list[i-1])


func get_recipe() -> Recipe:
	return recipe


func _initialize_children() -> void:
	ingredients.append(%ResourceBox2)
	ingredients.append(%ResourceBox3)
	ingredients.append(%ResourceBox4)
	ingredients.append(%ResourceBox5)
	ingredients.append(%ResourceBox6)

func _pressed() -> void:
	recipe_selected.emit(recipe)


# recipe clicked send global event with recipe?
# removes items from inventory and adds them to crafting bench
