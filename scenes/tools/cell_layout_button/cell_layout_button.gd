extends Button
class_name CellButton

signal selected(cell_button:CellButton)
signal type_changed(vector_location:Vector2)
signal exit_changed(id:int)

enum TYPE {NONE=0, EXIT, ENEMY,ITEM,OBSTACLE}

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

var enemy_tags : PackedInt32Array = []


func _pressed() -> void:
	selected.emit(self)
	toggle_highlight(true)


func reset() -> void:
	if id != -1:
		return
	type = TYPE.NONE
	enemy_tags = []


func set_type(x:String) -> void:
	match x:
		"EXIT":
			type = TYPE.EXIT
		"ENEMY":
			type = TYPE.ENEMY
		"ITEM":
			type = TYPE.ITEM
		"OBSTACLE":
			type = TYPE.OBSTACLE


func toggle_highlight(selected:bool)->void:
	if selected:
		modulate = Color.GREEN
	else:
		if type==TYPE.ENEMY:
			modulate = Color.RED
		else:
			modulate = Color.WHITE


func contains_tag(tag:int)->bool:
	return enemy_tags.has(tag)


func toggle_enemy_tag(tag:int,toggled_on:bool) -> void:
	if not toggled_on:
		if enemy_tags.has(tag):
			enemy_tags.remove_at(enemy_tags.find(tag))
	if toggled_on:
		if not enemy_tags.has(tag):
			enemy_tags.append(tag)
	print(enemy_tags)
