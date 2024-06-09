extends CanvasLayer
class_name MainUI

signal menu_opened
signal menu_closed

@onready var inventory: PanelContainer = %Inventory
@onready var crafting_inventory: CraftingInventory = %CraftingInventory

var any_menu_open : bool = false :
	set(value):
		if any_menu_open == value:
			return
		any_menu_open = value
		if any_menu_open:
			menu_opened.emit()
		else:
			menu_closed.emit()

var interactable_menu_open : bool = false :
	set(value):
		interactable_menu_open = value
		_set_any_menu_open()

var inventory_menu_open : bool = false :
	set(value):
		inventory_menu_open = value
		_set_any_menu_open()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		if not interactable_menu_open:
			_toggle_inventory_UI()

func _toggle_inventory_UI() -> void:
	if inventory.visible:
		inventory.visible = false
		inventory_menu_open = false
	else:
		inventory.visible = true
		inventory_menu_open = true

func interact(interaction_node:Node=null) -> void:
	if any_menu_open:
		if interactable_menu_open:
			_toggle_crafting_inventory_UI()
	
	if interaction_node == null:
		return
	
	if interaction_node.is_in_group("crafting_tables"):
		_toggle_crafting_inventory_UI()


func _toggle_crafting_inventory_UI() -> void:
	if crafting_inventory.visible:
		crafting_inventory.visible = false
		_toggle_inventory_UI()
		interactable_menu_open = false
	else:
		crafting_inventory.visible = true
		_toggle_inventory_UI()
		interactable_menu_open = true

func _set_any_menu_open() -> void:
	if interactable_menu_open or inventory_menu_open:
		any_menu_open = true
	elif not interactable_menu_open and not inventory_menu_open:
		any_menu_open = false
