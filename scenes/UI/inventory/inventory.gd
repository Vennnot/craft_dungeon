extends PanelContainer


@onready var item_inventory: GridContainer = %ItemInventory

func _ready() -> void:
	EventBus.orphan_item.connect(_orphan_item)


func _orphan_item(item:Item) -> void:
	item_inventory.add_item(item)
