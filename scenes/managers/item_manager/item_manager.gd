extends Node
class_name ItemManager

var active_item_controllers : Array[Node] = [null,null,null,null]
var item_controllers : Array[Node] = []


func _ready() -> void:
	InventoryManager.item_added.connect(_add_item)
	InventoryManager.item_removed.connect(_remove_item)
	InventoryManager.equipment_slot_updated.connect(_on_equipment_slot_updated)


func use_item(slot_number:int) -> void:
	if active_item_controllers[slot_number] == null:
		print("No item to use")
		return
	
	active_item_controllers[slot_number].use()


func _on_equipment_slot_updated(item:Item,slot_number:int) -> void:
	print("Updated equipment slots from item manager")
	var new_controller : Node = _add_item(item)
	_replace_active_item_controller(new_controller,slot_number)


func _add_item(item:Item) -> Node:
	if item == null:
		return null
	
	if _get_controller_from_item(item) != null:
		return null
	
	var controller_scene := item.controller_scene.instantiate()
	add_child(controller_scene)
	item_controllers.append(controller_scene)
	return controller_scene


func _remove_item(item:Item) -> void:
	if item == null:
		return
	
	var controller_to_remove := _get_controller_from_item(item)
	if controller_to_remove == null:
		print("Could not find item controller")
	if active_item_controllers.has(controller_to_remove):
		_replace_active_item_controller(null,active_item_controllers.find(controller_to_remove))
	
	item_controllers.erase(controller_to_remove)
	controller_to_remove.call_deferred("queue_free")


func _get_controller_from_item(item:Item) -> Node:
	if item == null:
		return null
	
	for controller in item_controllers:
		if controller.item == null:
			print("Controller doesn't have item assigned!")
		if controller.item == item:
			return controller
	return null


func _replace_active_item_controller(controller:Node, slot_number:int) -> void:
	active_item_controllers[slot_number] = controller


func get_look_direction() -> Vector2:
	return get_parent().look_direction
