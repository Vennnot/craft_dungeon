extends CanvasLayer



func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		_toggle_inventory_UI()
	elif Input.is_action_just_pressed("interact"):
		_toggle_crafting_UI()

func _toggle_inventory_UI() -> void:
	pass

func _toggle_crafting_UI() -> void:
	pass
