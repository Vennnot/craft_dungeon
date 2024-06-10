extends HBoxContainer
class_name EquipmentInventory

signal equipment_inventory_item_added(item:Item)
signal equipment_inventory_item_removed(item:Item)

var equipment_slots : Array[ResourceBox] = []

func _ready() -> void:
	_initialize_equipment_slots()

func _on_item_added(item:Item) -> void:
	equipment_inventory_item_added.emit(item)

func _on_item_removed(item:Item) -> void:
	equipment_inventory_item_removed.emit(item)

func _initialize_equipment_slots() -> void:
	var children : Array[ResourceBox] = [%ResourceBox1, %ResourceBox2, %ResourceBox3, %ResourceBox4]
	for resource_box in children:
		resource_box.added_item.connect(_on_item_added)
		resource_box.removed_item.connect(_on_item_removed)
