extends Control

@onready var line_edit: LineEdit = %LineEdit

func _ready() -> void:
	line_edit.text_submitted.connect(_debug_parser)


func _debug_parser(text_to_parse:String)-> void:
	var parts := text_to_parse.split("_",false)
	
	var add : bool
	if parts[0][0] == "a":
		add = true
	elif parts[0][0] == "r":
		add = false
	else:
		print("Invalid Command")
		return
	
	var item : bool
	if parts[0][1] == "i":
		item = true
	elif parts[0][1] == "m":
		item = false
	else:
		print("Invalid Command")
		return

	var amount : int = 1
	if parts.size() > 2:
		amount = int(parts[2])
	
	if add and item:
		InventoryManager.add_item(CraftingManager.get_item_by_id(parts[1]))
	elif add and not item:
		InventoryManager.add_crafting_material(CraftingManager.get_crafting_material_by_id((parts[1])),amount)
	elif not add and item:
		InventoryManager.remove_item(CraftingManager.get_item_by_id(parts[1]),false)
	elif not add and not item:
		InventoryManager.add_crafting_material(CraftingManager.get_crafting_material_by_id((parts[1])))

