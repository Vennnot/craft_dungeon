extends PanelContainer

@onready var quantity_label: Label = $QuantityLabel

var texture : Texture
var quantity : int :
	set(value):
		quantity = value
		if value < 2:
			quantity_label.visible = false
		else:
			quantity_label.visible = true
			quantity_label.text = "x"+str(quantity)

func _ready() -> void:
	quantity = 1
