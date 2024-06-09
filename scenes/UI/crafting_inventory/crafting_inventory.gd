extends PanelContainer
class_name CraftingInventory


@onready var craft_button: Button = %CraftButton
@onready var reset_button: Button = %ResetButton
@onready var ingredient_box_array : Array[ResourceBox] = [%IngredientBox1, %IngredientBox2, %IngredientBox3, %IngredientBox4, %IngredientBox5]
@onready var result_box: ResourceBox = %ResultBox



func _ready() -> void:
	reset_button.pressed.connect(_on_reset_pressed)


func _on_reset_pressed() -> void:
	for ingredient in ingredient_box_array:
		ingredient.restore_original_values()
		ingredient.reset()

func _on_menu_close() -> void:
	_on_reset_pressed()
	pass
	# send result resource back to inventory but how?
	# add method in inventory for items
