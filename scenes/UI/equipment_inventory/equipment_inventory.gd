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


func add_item(item:Item) -> void:
	for resource_box in get_children():
		if resource_box.item == null:
			resource_box.item = item
			resource_box.quantity += 1
			return

func remove_item(item:Item) -> void:
	for resource_box in get_children():
		if resource_box.item == item:
			#might need to set item to null here
			resource_box.quantity -= 1
			return
