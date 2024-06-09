extends PanelContainer
class_name ResourceBox

signal contents_changed(contents, id)

@export var drag_preview_instance : PackedScene

@onready var quantity_label: Label = $QuantityLabel
@onready var texture_rect: TextureRect = $TextureRect


@export var in_inventory : bool = false
@export var is_result : bool = false

@export_category("Material")
@export var crafting_material : CraftingMaterial
@export var is_exclusively_material_slot : bool = false

@export_category("Item")
@export var item : Item
@export var is_exclusively_item_slot : bool = false
@export var is_passive_item_slot : bool = false
@export var is_active_item_slot : bool = false

@export_category("Misc")
@export var is_crafting_slot : bool = false
@export var id : int = 0

var quantity : int :
	set(value):
		if value < 0:
			value = 0
		if item == null and crafting_material == null:
			value = 0
		if item != null and value > 1:
			value = 1
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
	
	if is_crafting_slot:
		contents_changed.emit(_get_resource(),id)


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
		data["origin_resource"]= _get_resource()
		
		var drag_preview := drag_preview_instance.instantiate()
		drag_preview.texture = _get_texture()
		add_child(drag_preview)
	
	return data


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return _check_combatibility(data)


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	#restores values if replaced outside from within or outside by outside
	if not (data["origin_node"].in_inventory and data["target_node"].in_inventory):
		restore_original_values()
	_set_original_owner(data)
	
	
	var origin_item : Resource = data["origin_resource"].duplicate()
	
	#swaps items when in inventory
	if data["origin_node"].in_inventory and data["target_node"].in_inventory and (data["origin_node"].item != null and data["target_node"].item != null):
		data["origin_node"].item = item
		data["origin_node"].quantity += 0
	else:
		data["origin_node"].quantity -= 1
	
	#slot has material now
	if data["origin_node"].crafting_material != null:
		if item != null:
			item = null
			quantity = 0
		crafting_material = data["origin_resource"]
	
	# slot has item now
	else:
		if crafting_material != null:
			crafting_material = null
			quantity = 0
		item = origin_item
	
	quantity += 1


func restore_original_values() -> void:
	if original_owner != null and (item != null or crafting_material != null):
		if original_owner.item != null:
			EventBus.emit_orphan_item(item)
		else:
			original_owner.item = item
			original_owner.crafting_material = crafting_material
			original_owner.quantity += 1
		original_owner = null


func reset() -> void:
	quantity = 0
	original_owner = null


func _set_original_owner(data:Variant) -> void:
	if data["origin_node"].in_inventory:
		original_owner = data["origin_node"]
	else:
		original_owner = data["origin_node"].original_owner
		data["origin_node"].original_owner = null


func _check_combatibility(data:Variant) -> bool:
	if not data:
		return false
	
	if is_result:
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
			if data["target_node"].is_passive_item_slot:
				return data["origin_node"].is_passive_item_slot == data["target_node"].is_passive_item_slot
			elif data["target_node"].is_active_item_slot:
				return data["origin_node"].is_active_item_slot == data["target_node"].is_active_item_slot
			return data["origin_node"].is_exclusively_item_slot == data["target_node"].is_exclusively_item_slot
		return true
	
	#from outside to inventory
	if not data["origin_node"].in_inventory and data["target_node"].in_inventory:
		if data["target_node"].is_exclusively_material_slot:
			return data["origin_node"].crafting_material != null
		elif data["target_node"].is_exclusively_item_slot:
			if data["origin_node"].item == null:
				return false
			if data["target_node"].is_passive_item_slot:
				return data["origin_node"].item.is_passive
			elif data["target_node"].is_active_item_slot:
				return not data["origin_node"].item.is_passive
		return true

	
	#from inventory to inventory
	if data["origin_node"].is_exclusively_material_slot or data["target_node"].is_exclusively_material_slot:
		return false
	if data["origin_node"].is_exclusively_item_slot != data["target_node"].is_exclusively_item_slot:
		return false
	if data["origin_node"].is_passive_item_slot != data["target_node"].is_passive_item_slot:
		return false
	if data["target_node"].is_active_item_slot:
		return not data["origin_resource"].is_passive
	if data["origin_node"].is_active_item_slot and item != null:
		return not item.is_passive
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
		print("Get Resource returned null")
		return null
