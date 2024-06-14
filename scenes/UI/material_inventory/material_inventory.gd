extends GridContainer
class_name MaterialInventory


var crafting_material_boxes : Array[ResourceBox]


func _ready() -> void:
	for resource_box in get_children():
		crafting_material_boxes.append(resource_box)


func add_crafting_material(crafting_material:CraftingMaterial, amount:int) -> void:
	for resource_box in crafting_material_boxes:
		if resource_box.crafting_material == crafting_material:
			resource_box.set_quantity(amount,true)
			return
	
	for resource_box in crafting_material_boxes:
		if resource_box.crafting_material == null:
			resource_box.set_resource(crafting_material)
			resource_box.set_quantity(amount)
			return


func remove_crafting_material(crafting_material:CraftingMaterial,amount:int) -> void:
	for resource_box in crafting_material_boxes:
		if resource_box.crafting_material == crafting_material:
			resource_box.set_quantity(-amount, true)
			return
