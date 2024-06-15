extends HBoxContainer
class_name EquipmentInventory

var equipment_resource_boxes : Array[ResourceBox] = []

func _ready() -> void:
	_initialize_equipment_resource_boxes()


func _initialize_equipment_resource_boxes() -> void:
	var children : Array[ResourceBox] = [%ResourceBox1, %ResourceBox2, %ResourceBox3, %ResourceBox4]
	for resource_box in children:
		equipment_resource_boxes.append(resource_box)
		resource_box.added_item.connect(_on_item_added)


func add_item(item:Item) -> void:
	for resource_box in equipment_resource_boxes:
		if resource_box.item == null:
			resource_box.set_resource(item)
			resource_box.set_quantity(1)
			return

func remove(item:Item) -> void:
	for resource_box in get_children():
		if resource_box.item == item:
			resource_box.set_quantity(-1,true)
			return


func _on_item_added(item:Item,id:int):
	InventoryManager.update_equipment_slot(item,id)
