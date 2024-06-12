extends PanelContainer

@onready var item_inventory: ItemInventory = %ItemInventory
@onready var material_inventory: MaterialInventory = %MaterialInventory
@onready var equipment_inventory: EquipmentInventory = %EquipmentInventory
@onready var stats_display: VBoxContainer = %StatsDisplay


func _ready() -> void:
	InventoryManager.orphan_UI_item.connect(_orphan_item)
	InventoryManager.item_added.connect(_add_item)
	InventoryManager.item_removed.connect(_remove_item)
	InventoryManager.crafting_material_added.connect(_add_crafting_material)
	InventoryManager.crafting_material_removed.connect(_remove_crafting_material)


func _orphan_item(item:Item) -> void:
	item_inventory.add_item(item)

func _add_item(item:Item) -> void:
	item_inventory.add_item(item)

func _remove_item(item:Item,is_equipment:bool) -> void:
	if is_equipment:
		equipment_inventory.remove(item)
	else:
		item_inventory.remove(item)

func _add_crafting_material(crafting_material:CraftingMaterial,amount:int) -> void:
	material_inventory.add_crafting_material(crafting_material, amount)

func _remove_crafting_material(crafting_material:CraftingMaterial,amount:int) -> void:
	material_inventory.remove_crafting_material(crafting_material, amount)
