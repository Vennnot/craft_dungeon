extends PanelContainer
class_name MaterialBox

@export var drag_preview_instance : PackedScene
@export var in_inventory : bool = true

@onready var quantity_label: Label = $QuantityLabel
@onready var texture_rect: TextureRect = $TextureRect

@export var crafting_material : CraftingMaterial :
	set(value):
		crafting_material = value
		if texture_rect != null:
			_update_crafting_material()

var quantity : int :
	set(value):
		if value < 0:
			value = 0
		quantity = value
		_quantity_validator()

# When an item outside of the inventory is replaced by an item internally
var original_owner : MaterialBox = null

func _ready() -> void:
	quantity = 1
	_update_crafting_material()


func _update_crafting_material() -> void:
	if crafting_material != null:
		texture_rect.texture = crafting_material.texture
	else:
		texture_rect.texture = null

func _quantity_validator() -> void:
	if quantity == 0:
		texture_rect.modulate.a = 0.5
		if not in_inventory:
			crafting_material = null
	elif quantity > 0:
		texture_rect.modulate.a = 1

	if not in_inventory:
		return
	quantity_label.visible = true
	quantity_label.text = "x"+str(quantity)

func _get_drag_data(_at_position: Vector2) -> Variant:
	var data = {}
	
	if crafting_material != null and quantity > 0:
		data["origin_node"]= self
		data["origin_crafting_material"]= crafting_material
		
		var drag_preview := drag_preview_instance.instantiate()
		drag_preview.texture = crafting_material.texture
		add_child(drag_preview)
	
	return data


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	data["target_node"] = self
	return _check_material_box_combatibility(data)

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	_restore_original_values(data)
	
	crafting_material = data["origin_crafting_material"]
	data["origin_node"].quantity -= 1
	quantity += 1

func _check_material_box_combatibility(data:Variant) -> bool:
	if not data:
		return false
	
	if data["origin_node"] == self:
		return false
	
	var compatible : bool = data["origin_node"] is MaterialBox and data["target_node"] is MaterialBox
	
	return compatible

func _set_original_owner(data:Variant) -> void:
	if data["origin_node"].in_inventory and not in_inventory:
		original_owner = data["origin_node"]
	elif not data["origin_node"].in_inventory and not in_inventory:
		original_owner = data["origin_node"].original_owner
	else:
		original_owner = null


func _restore_original_values(data:Variant) -> void:
	if original_owner != null and data["origin_node"].in_inventory and not in_inventory:
		original_owner.quantity += 1
		original_owner = null
	_set_original_owner(data)
