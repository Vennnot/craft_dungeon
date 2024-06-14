extends PanelContainer
class_name ResourceBox

signal contents_changed(contents, id)
signal added_item(item,id)
signal dropped_data

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

var quantity : int = 0 :
	set(value):
		if value < 0:
			value = 0
		quantity = value

var original_owner : ResourceBox = null

func _ready() -> void:
	update_texture()
	set_quantity(1,true)
	
	if is_exclusively_material_slot:
		quantity_label.visible=true



func _update_label() -> void:
	if quantity == 0:
		toggle_texture_opaqueness(true)
	elif quantity > 0:
		toggle_texture_opaqueness(false)
	
	quantity_label.text = "x"+str(quantity)


func _get_drag_data(_at_position: Vector2) -> Variant:
	var data = {}
	
	if not is_result and (item != null or (crafting_material != null and quantity > 0)):
		data["origin_node"] = self
		data["origin_resource"]= _get_resource()
		
		var drag_preview := drag_preview_instance.instantiate()
		drag_preview.texture = _get_resource_texture()
		add_child(drag_preview)
	
	return data


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return _check_combatibility(data)


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if is_crafting_slot:
		dropped_data.emit()
	
	#restores values if replaced outside from within or outside by outside
	if not (data["origin_node"].in_inventory and data["target_node"].in_inventory):
		restore_original_values()
	_set_original_owner(data)
	
	
	var origin_item : Resource = data["origin_resource"].duplicate()
	
	#swaps items when in inventory
	if data["origin_node"].in_inventory and data["target_node"].in_inventory and (data["origin_node"].item != null and data["target_node"].item != null):
		data["origin_node"].set_resource(item)
	else:
		data["origin_node"].set_quantity(-1,true)
	
	#slot has material now
	if data["origin_resource"] is CraftingMaterial:
		set_resource(data["origin_resource"]) 
		set_quantity(1)
	# slot has item now
	elif data["origin_resource"] is Item:
		set_resource(origin_item)
		set_quantity(1)


func restore_original_values() -> void:
	if original_owner != null:
		if item != null:
			if original_owner.item != null:
				InventoryManager.emit_orphan_UI_item(item)
			else:
				original_owner.set_resource(item)
				original_owner.set_quantity(1)
		elif crafting_material != null:
			if original_owner.crafting_material != null:
				original_owner.set_quantity(1, true)
		else:
			original_owner.set_quantity(0)
	else:
		if item != null:
			InventoryManager.emit_orphan_UI_item(item)
		elif crafting_material != null:
			InventoryManager.emit_orphan_UI_crafting_material(crafting_material)

	original_owner = null


func reset() -> void:
	set_resource(null)
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
			return data["origin_node"].crafting_material != null and data["origin_node"].crafting_material == data["target_node"].crafting_material
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


func _get_resource_texture() -> Texture:
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
		return null


func set_texture(texture:Texture) -> void:
	texture_rect.texture = texture

func toggle_texture_opaqueness(opaque:bool=false) -> void:
	if opaque:
		texture_rect.modulate.a = 0.5
	else:
		texture_rect.modulate.a = 1


func update_texture() -> void:
	set_texture(_get_resource_texture())


func set_resource(resource:Resource) -> void:
	
	if resource is CraftingMaterial:
		item = null
		crafting_material = resource
	elif resource is Item:
		crafting_material = null
		item =resource
	elif resource == null:
		crafting_material = null
		item = null
	
	if is_active_item_slot:
		added_item.emit(resource,id)
	
	update_texture()
	
	if is_crafting_slot:
		contents_changed.emit(_get_resource(),id)


func set_quantity(amount:int,add:bool=false) -> void:
	if item == null and crafting_material == null:
		_update_label()
		return
	
	if add:
		quantity += amount
		if item != null and quantity > 1:
			quantity = 1
	else:
		quantity = amount
	
	_quantity_check()
	_update_label()


func _quantity_check():
	if quantity == 0:
		if in_inventory:
			if item != null and crafting_material == null:
				set_resource(null)
		else:
			set_resource(null)
