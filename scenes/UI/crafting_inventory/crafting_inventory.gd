extends PanelContainer
class_name CraftingInventory

@onready var ingredients_h_box_container: HBoxContainer = %IngredientsHBoxContainer

@onready var craft_button: Button = %CraftButton
@onready var reset_button: Button = %ResetButton
@onready var ingredient_boxes : Array[ResourceBox] = []
@onready var result_box: ResourceBox = %ResultBox
@onready var recipe_list: RecipeList = %RecipeList

var ingredients : Array[Resource] = [null,null,null,null,null]

var result : Item :
	set(value):
		result = value
		if result == null:
			_reset_box_visuals()
		_generate_preview()

func _ready() -> void:
	_initialize_children()
	craft_button.disabled=true
	reset_button.pressed.connect(_on_reset_pressed)
	craft_button.pressed.connect(_on_craft_pressed)
	InventoryManager.recipe_selected.connect(_on_recipe_selected)


func _initialize_children() -> void:
	for ingredient_box in ingredients_h_box_container.get_children():
		ingredient_boxes.append(ingredient_box)
		ingredient_box.contents_changed.connect(_on_contents_changed)
		ingredient_box.dropped_data.connect(_reset_box_visuals)



func _on_reset_pressed() -> void:
	_reset_box_visuals()

	for ingredient_box in ingredient_boxes:
		ingredient_box.restore_original_values()
	
	result_box.restore_original_values()
	_reset_box_content()


func _on_craft_pressed() -> void:
	InventoryManager.emit_orphan_UI_item(result)
	
	_reset_box_content()


func on_menu_close() -> void:
	_on_reset_pressed()


func _on_contents_changed(ingredient:Resource, id:int) -> void:
	ingredients[id] = ingredient
	_get_result()


func _get_result() -> void:
	result = CraftingManager.get_resource(ingredients)


func _set_result(id:StringName) -> void:
	result = CraftingManager.get_item_by_id(id)


func _generate_preview() -> void:
	if result == null:
		craft_button.disabled=true
		result_box.set_texture(null)
		return
	
	
	if CraftingManager.get_resource(ingredients)!=null:
		craft_button.disabled = false
	
	result_box.set_texture(result.texture)
	result_box.toggle_texture_opaqueness(true)


func _on_recipe_selected(recipe:Recipe) -> void:
	_on_reset_pressed()
	var ingredients_list := recipe.ingredients_list.filter(func(element:Variant): return element != null)
	for i in ingredients_list.size():
		if ingredients_list[i] is Item:
			if InventoryManager.has_item(ingredients_list[i]):
				ingredient_boxes[i].set_resource(ingredients_list[i])
				ingredient_boxes[i].set_quantity(1)
			else:
				ingredient_boxes[i].set_texture(ingredients_list[i].texture)
				ingredient_boxes[i].toggle_texture_opaqueness(true)
		elif ingredients_list[i] is CraftingMaterial:
			if InventoryManager.has_crafting_material(ingredients_list[i]):
				ingredient_boxes[i].set_resource(ingredients_list[i])
				ingredient_boxes[i].set_quantity(1)
			else:
				ingredient_boxes[i].set_texture(ingredients_list[i].texture)
				ingredient_boxes[i].toggle_texture_opaqueness(true)

	_set_result(recipe.result_item.id)


func _reset_box_visuals() -> void:
	for ingredient_box in ingredient_boxes:
		ingredient_box.update_texture()

	result_box.update_texture()


func _reset_box_content() -> void:
	for ingredient_box in ingredient_boxes:
		ingredient_box.reset()

	result_box.reset()
