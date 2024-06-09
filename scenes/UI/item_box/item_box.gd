extends PanelContainer
class_name ItemBox

#TODO currently doesn't accept replacing an out of inventory 
#		item with an in inventory one

@export var drag_preview_instance : PackedScene

@onready var quantity_label: Label = $QuantityLabel
@onready var texture_rect: TextureRect = $TextureRect

@export var item : Item :
	set(value):
		item = value
		if texture_rect != null:
			_update_item_texture()

@export var is_passive : bool = false
@export var is_active : bool = false

var quantity : int :
	set(value):
		if value < 0:
			value = 0
		quantity = value
		_quantity_validator()

func _ready() -> void:
	quantity = 1
	_update_item_texture()


func _update_item_texture() -> void:
	if item == null:
		texture_rect.texture = null
	else:
		texture_rect.texture = item.texture


func reset_item() -> void:
	item = null
	quantity = 0


func _quantity_validator() -> void:
	if quantity == 1:
		quantity_label.visible = false
	elif quantity > 1:
		quantity_label.text = "x"+str(quantity)
		quantity_label.visible = true

func _get_drag_data(_at_position: Vector2) -> Variant:
	var data = {}
	
	if item != null:
		data["origin_node"]= self
		data["origin_item"]= item
		
		var drag_preview := drag_preview_instance.instantiate()
		drag_preview.texture = item.texture
		add_child(drag_preview)
	
	return data


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return _check_item_box_combatibility(data)


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	item = data["origin_item"]
	data["origin_node"].reset_item()


func _check_item_box_combatibility(data:Variant) -> bool:
	if not data:
		return false
	
	if data["origin_node"] == self:
		return false
	
	data["target_node"] = self
	var compatible : bool = data["origin_node"] is ItemBox and data["target_node"] is ItemBox
	if not compatible:
		return compatible
	
	if data["origin_node"].is_passive != data["target_node"].is_passive:
		return false
	if data["origin_node"].is_active != data["target_node"].is_active:
		return false

	return compatible
