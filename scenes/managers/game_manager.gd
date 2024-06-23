extends Node

var player : Player = null
var ui : MainUI = null

func _ready() -> void:
	_get_player()
	_get_ui()
	Camera.set_limit_target("../../Test/GameManager/TileMap")
	ui.menu_opened.connect(_ui_menu_opened)
	ui.menu_closed.connect(_ui_menu_closed)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		_interact()


func _interact() -> void:
	if ui.any_menu_open:
		ui.interact()
	elif player.interaction_nodes:
		if player.interaction_nodes[0].is_in_group("interactable_menus"):
			ui.interact(player.interaction_nodes[0])
	else:
		player.interact()


func _ui_menu_opened() -> void:
	player.input_disabled = true


func _ui_menu_closed() -> void:
	player.input_disabled = false


func _get_player() -> void:
	player = get_tree().get_first_node_in_group("player")

func _get_ui() -> void:
	ui = get_tree().get_first_node_in_group("main_ui")
