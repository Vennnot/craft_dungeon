extends Node

var equipped_items : Array[Item] = [null,null,null,null]


func _ready() -> void:
	InventoryManager.equipment_slot_updated.connect(_on_equipment_slot_updated)


func _on_equipment_slot_updated(item:Item,slot_number:int) -> void:
	equipped_items[slot_number] = item
