extends PanelContainer

@onready var item_inventory: ItemInventory = %ItemInventory
@onready var material_inventory: GridContainer = %MaterialInventory
@onready var equipment_inventory: EquipmentInventory = %EquipmentInventory
@onready var stats_display: VBoxContainer = %StatsDisplay
#
#var equipped_items : Array[Item] = []
#var inventory_items : Array[Item] = []
#var crafting_materials : Dictionary = {}

func _ready() -> void:
	InventoryManager.orphan_UI_item.connect(_orphan_item)
	InventoryManager.item_added.connect(_add_item)
	
	#item_inventory.inventory_item_added.connect(_add_item.bind(false))
	#item_inventory.inventory_item_removed.connect(_remove_item.bind(false))
	#
	#equipment_inventory.equipment_inventory_item_added.connect(_add_item.bind(true))
	#equipment_inventory.equipment_inventory_item_removed.connect(_remove_item.bind(true))


func _orphan_item(item:Item) -> void:
	item_inventory.add_item(item)

func _add_item(item:Item,is_equipment:bool=false) -> void:
	print("got here")
	if is_equipment:
		pass
	else:
		item_inventory.add_item(item)
#
#func _remove_item(item:Item,is_equipment:bool) -> void:
	#if is_equipment:
		#equipped_items.erase(item)
	#else:
		#inventory_items.erase(item)
	#
	#print("Removed item: %s" % item)
#
#func _add_crafting_material(crafting_material:CraftingMaterial) -> void:
	#crafting_materials[crafting_material] += 1
	#
	#print("Added crafting material: %s" % crafting_material)
#
#func _remove_crafting_material(crafting_material:CraftingMaterial) -> void:
	#crafting_materials[crafting_material] -= 1
	#
	#print("Removed crafting material: %s" % crafting_material)
