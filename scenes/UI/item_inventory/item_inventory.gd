extends GridContainer
class_name ItemInventory

signal inventory_item_added(item:Item)
signal inventory_item_removed(item:Item)

func _ready() -> void:
	for resource_box in get_children():
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


func _on_item_added(item:Item) -> void:
	inventory_item_added.emit(item)

func _on_item_removed(item:Item) -> void:
	inventory_item_removed.emit(item)
