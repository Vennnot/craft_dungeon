extends PanelContainer
class_name ResourceBox

@export var drag_preview_instance : PackedScene

@onready var quantity_label: Label = $QuantityLabel
@onready var texture_rect: TextureRect = $TextureRect


@export var in_inventory : bool = false

@export_category("Material")
@export var crafting_material : CraftingMaterial
@export var is_exclusively_material_slot : bool = false

@export_category("Item")
@export var item : Item
@export var is_exclusively_item_slot : bool = false
@export var is_passive_item : bool = false
@export var is_active_item : bool = false

var quantity : int :
	set(value):
		if value < 0:
			value = 0
		if item == null and crafting_material == null:
			value = 0
		quantity = value
		_update_resource()
		_update_display()

var original_owner : ResourceBox = null

func _ready() -> void:
	quantity = 1


func _update_resource():
	if in_inventory:
		if quantity == 0:
			if crafting_material != null:
				pass
			else:
				item = null
	else:
		if quantity == 0:
			if crafting_material != null:
				crafting_material = null
			else:
				item = null


func _update_display() -> void:
	if not crafting_material != null:
		quantity_label.visible = false
	elif quantity == 0:
		texture_rect.modulate.a = 0.5
		if item == null and not is_exclusively_material_slot:
			quantity_label.visible = false
	elif quantity > 0:
		texture_rect.modulate.a = 1
		if in_inventory:
			quantity_label.visible = true
	
	quantity_label.text = "x"+str(quantity)
	texture_rect.texture = _get_texture()


func _get_drag_data(_at_position: Vector2) -> Variant:
	var data = {}
	
	if item != null or (crafting_material != null and quantity > 0):
		data["origin_node"] = self
		data["origin_is_crafting_material"] = crafting_material != null
		data["origin_resource"]= _get_resource()
		
		var drag_preview := drag_preview_instance.instantiate()
		drag_preview.texture = _get_texture()
		add_child(drag_preview)
	
	return data


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return _check_combatibility(data)


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	_restore_original_values(data)
	
	if data["origin_is_crafting_material"]:
		item = null
		quantity = 0
		crafting_material = data["origin_resource"]
	else:
		crafting_material = null
		quantity = 0
		item = data["origin_resource"]
	
	quantity += 1
	data["origin_node"].quantity -= 1


func _restore_original_values(data:Variant) -> void:
	if in_inventory:
		return
	
	if original_owner != null:
		if item != null:
			original_owner.item = item
		original_owner.quantity += 1
		original_owner = null
	
	_set_original_owner(data)


func _set_original_owner(data:Variant) -> void:
	if data["origin_node"].in_inventory:
		original_owner = data["origin_node"]
	elif not data["origin_node"].in_inventory:
		original_owner = data["origin_node"].original_owner
		data["origin_node"].original_owner = null


func _check_combatibility(data:Variant) -> bool:
	if not data:
		return false
	
	if data["origin_node"] == self:
		return false
	
	data["target_node"] = self
	
	if data["origin_node"] is ResourceBox != data["target_node"] is ResourceBox:
		return false
	
	#from inventory to outside and outside to outside
	if not data["target_node"].in_inventory:
		if data["target_node"].is_exclusively_material_slot:
			return data["origin_node"].is_exclusively_material_slot == data["target_node"].is_exclusively_material_slot
		elif data["target_node"].is_exclusively_item_slot:
			if data["target_node"].is_passive_item:
				return data["origin_node"].is_passive_item == data["target_node"].is_passive_item
			elif data["target_node"].is_active_item:
				return data["origin_node"].is_active_item == data["target_node"].is_active_item
			return data["origin_node"].is_exclusively_item_slot == data["target_node"].is_exclusively_item_slot
		return true
	
	#from outside to inventory
	if data["target_node"].in_inventory:
		if data["target_node"].is_exclusively_material_slot:
			return data["origin_node"].crafting_material != null
		elif data["target_node"].is_exclusively_item_slot:
			if data["origin_node"].item == null:
				return false
			if data["target_node"].is_passive_item:
				return data["origin_node"].item.is_passive
			elif data["target_node"].is_active_item:
				return not data["origin_node"].item.is_passive
		return true

	
	#from inventory to inventory
	if data["origin_node"].is_exclusively_material_slot != data["target_node"].is_exclusively_material_slot:
		return false
	if data["origin_node"].is_exclusively_item_slot != data["target_node"].is_exclusively_item_slot:
		return false
	if data["origin_node"].is_passive_item != data["target_node"].is_passive_item:
		return false
	if data["origin_node"].is_active_item != data["target_node"].is_active_item:
		return false

	return true


func _get_texture() -> Texture:
	if item != null:
		return item.texture
	elif crafting_material != null:
		return crafting_material.texture
	else:
		return null


func _get_resource() -> Resource:
	if item != null:
		return item
	elif crafting_material != null:
		return crafting_material
	else:
		print("Drag data registered null resource")
		return null
