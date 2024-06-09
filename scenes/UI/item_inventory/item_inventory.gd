extends GridContainer

var items_array : Array[ResourceBox]

func _ready() -> void:
	for resource_box in get_children():
		items_array.append(resource_box)

func add_item(item:Item) -> void:
	for resource_box in get_children():
		if resource_box.item == null:
			resource_box.item = item
			resource_box.quantity += 1
