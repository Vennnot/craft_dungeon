extends PanelContainer
class_name CraftingInventory

@onready var ingredients_h_box_container: HBoxContainer = %IngredientsHBoxContainer

@onready var craft_button: Button = %CraftButton
@onready var reset_button: Button = %ResetButton
@onready var ingredient_boxes : Array[ResourceBox] = []
@onready var result_box: ResourceBox = %ResultBox

var ingredients : Array[Resource] = [null,null,null,null,null]

var result : Item :
	set(value):
		result = value
		result_box.item = result
		result_box.quantity += 1

func _ready() -> void:
	_initialize_children()
	reset_button.pressed.connect(_on_reset_pressed)


func _on_reset_pressed() -> void:
	for ingredient_box in ingredient_boxes:
		ingredient_box.restore_original_values()
		ingredient_box.reset()
	
	result_box.restore_original_values()
	result_box.reset()


func on_menu_close() -> void:
	_on_reset_pressed()

func _initialize_children() -> void:
	for ingredient_box in ingredients_h_box_container.get_children():
		ingredient_boxes.append(ingredient_box)
		ingredient_box.contents_changed.connect(_on_contents_changed)


func _on_contents_changed(ingredient:Resource, id:int) -> void:
	ingredients[id] = ingredient
	result = CraftingManager.get_resource(ingredients)
