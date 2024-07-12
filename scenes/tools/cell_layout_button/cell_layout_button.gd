extends Button
class_name CellButton

signal selected(cell_button:CellButton)
signal type_changed(vector_location:Vector2)
signal exit_changed(id:int)

enum TYPE {NONE=0, EXIT, ENEMY,ITEM,INTERACTABLE}

var type : TYPE = TYPE.NONE :
	set(value):
		type = value
		type_changed.emit(vector_location)

var id : int = -1 :
	set(value):
		id = value
		if id!=-1:
			type = TYPE.EXIT


var is_exit_open : bool = true :
	set(value):
		is_exit_open = value
		exit_changed.emit(id)

var vector_location : Vector2 = Vector2.ZERO

func _pressed() -> void:
	selected.emit(self)
	toggle_highlight()


func reset() -> void:
	if id != -1:
		return
	type = TYPE.NONE


func set_type(x:String) -> void:
	match x:
		"EXIT":
			type = TYPE.EXIT
		"ENEMY":
			type = TYPE.ENEMY
		"ITEM":
			type = TYPE.ITEM
		"INTERACTABLE":
			type = TYPE.INTERACTABLE


func toggle_highlight()->void:
	if modulate != Color.WHITE:
		modulate = Color.GREEN
	else:
		modulate = Color.WHITE
