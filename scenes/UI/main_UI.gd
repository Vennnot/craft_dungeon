extends CanvasLayer
class_name MainUI

signal menu_opened
signal menu_closed

@onready var inventory: PanelContainer = %Inventory
@onready var crafting_inventory: CraftingInventory = %CraftingInventory
@onready var tooltip: PopupPanel = %Tooltip
@onready var tooltip_timer: Timer = %TooltipTimer

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

func _ready() -> void:
	EventBus.item_mouse_entered.connect(_tooltip_timer_start)
	EventBus.item_mouse_exited.connect(hide_item_popup)
	tooltip_timer.timeout.connect(_on_tooltip_timer_timeout)


func _tooltip_timer_start(item:Item) -> void:
	_update_tooltip(item)
	tooltip_timer.start()


func _update_tooltip(item:Item) -> void:
	tooltip.id_label.text = item.id

func _on_tooltip_timer_timeout() -> void:
	show_item_popup()


func show_item_popup() -> void:
	var popup_position : Vector2 = get_viewport().get_mouse_position()
	popup_position += Vector2(20.0,-tooltip.size.y/3.0)
	tooltip.popup(Rect2i(popup_position,tooltip.size))


func hide_item_popup() -> void:
	tooltip.hide()



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
		crafting_inventory.on_menu_close()
	else:
		crafting_inventory.visible = true
		_toggle_inventory_UI()
		interactable_menu_open = true

func _set_any_menu_open() -> void:
	if interactable_menu_open or inventory_menu_open:
		any_menu_open = true
	elif not interactable_menu_open and not inventory_menu_open:
		any_menu_open = false
