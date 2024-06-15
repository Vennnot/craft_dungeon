extends GridContainer
class_name ItemInventory

var item_boxes : Array[ResourceBox]

func _ready() -> void:
	for resource_box in get_children():
		item_boxes.append(resource_box)

func add_item(item:Item) -> void:
	for resource_box in item_boxes:
		if resource_box.item == null:
			resource_box.set_resource(item)
			resource_box.set_quantity(1)
			return

func remove(item:Item) -> void:
	for resource_box in item_boxes:
		if resource_box.item == item:
			resource_box.set_quantity(-1,true)
			return
