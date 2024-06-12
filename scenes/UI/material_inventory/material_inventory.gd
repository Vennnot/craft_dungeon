extends GridContainer
class_name MaterialInventory


func add_crafting_material(crafting_material:CraftingMaterial,amount:int) -> void:
	for resource_box in get_children():
		if resource_box.crafting_material == crafting_material:
			resource_box.quantity += amount
			return
	
	for resource_box in get_children():
		if resource_box.crafting_material == null:
			resource_box.crafting_material = crafting_material
			resource_box.quantity += amount
			return

func remove_crafting_material(crafting_material:CraftingMaterial,amount:int) -> void:
	for resource_box in get_children():
		if resource_box.crafting_material == crafting_material:
			resource_box.quantity -= amount
			return
