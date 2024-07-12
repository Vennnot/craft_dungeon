extends Button
class_name CellButton

var id : int = -1
var vector_location : Vector2 = Vector2.ZERO

func _pressed() -> void:
	print(vector_location)
