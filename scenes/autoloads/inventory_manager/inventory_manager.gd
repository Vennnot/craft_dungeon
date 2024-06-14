extends Node

signal item_added(item)
signal item_removed(item)
signal item_to_inventory(item)
signal item_to_equipment(item)
signal crafting_material_added(crafting_material, amount)
signal crafting_material_removed(crafting_material, amount)
signal recipe_selected(recipe)


var equipped_items : Array[Item] = [null,null,null,null]

var items : Array[Item] = []
var crafting_materials : Dictionary = {}

func _ready() -> void:
	_initialize_crafting_materials()


func has_item(item:Item) -> bool:
	return equipped_items.has(item) or items.has(item)


func has_crafting_material(crafting_material:CraftingMaterial) -> bool:
	return crafting_materials[crafting_material] > 0


func add_item(item:Item) -> void:
	items.append(item)
	
	item_added.emit(item)
	print("Added item: %s" % item)

func remove_item(item:Item,is_equipment:bool) -> void:
	if is_equipment:
		equipped_items.erase(item)
	else:
		items.erase(item)
	
	item_removed.emit(item)
	print("Removed item: %s" % item)

func add_crafting_material(crafting_material:CraftingMaterial,amount:int=1) -> void:
	crafting_materials[crafting_material] += amount
	
	crafting_material_added.emit(crafting_material,amount)
	print("Added crafting material: %s" % crafting_material)

func remove_crafting_material(crafting_material:CraftingMaterial,amount:int=1) -> void:
	crafting_materials[crafting_material] -= amount
	
	crafting_material_removed.emit(crafting_material,amount)
	
	if crafting_materials[crafting_material] < 0:
		crafting_materials[crafting_material] = 0
	print("Removed crafting material: %s" % crafting_material)


func update_equipment_slot(new_item:Item,slot_number:int):
	equipped_items[slot_number] = new_item


func switch_item_to_equipment(item:Item) -> void:
	items.erase(item)
	equipped_items.append(item)


func switch_item_to_inventory(item:Item) -> void:
	equipped_items.erase(item)
	items.append(item)


func _initialize_crafting_materials() -> void:
	for crafting_material in CraftingManager.all_crafting_materials:
		crafting_materials[crafting_material] = 0


func emit_recipe_selected(recipe:Recipe) -> void:
	recipe_selected.emit(recipe)


signal orphan_UI_item(item:Item)

func emit_orphan_UI_item(item:Item):
	orphan_UI_item.emit(item)

signal orphan_UI_crafting_material(crafting_material:CraftingMaterial)

func emit_orphan_UI_crafting_material(crafting_material:CraftingMaterial):
	orphan_UI_crafting_material.emit(crafting_material)
