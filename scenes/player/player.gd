extends CharacterBody2D
class_name Player

@export_group("Movement","movement")
@export var movement_speed : float = 100
@export var movement_friction : float = 0.18

@onready var interaction_area: Area2D = $InteractionArea
@onready var item_manager: ItemManager = %ItemManager
@onready var health_component: HealthComponent = %HealthComponent

var input_disabled : bool = false
var interaction_nodes : Array[Node] = []
var movement_direction : Vector2 = Vector2.ZERO
var look_direction : Vector2 = Vector2.RIGHT

func _ready() -> void:
	interaction_area.area_entered.connect(_on_interaction_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_exited)
	Camera.set_follow_target(self)


func _physics_process(_delta) -> void:
	movement_direction = _get_movement_direction()
	look_direction = _get_look_direction()
	
	
	if input_disabled:
		movement_direction = Vector2.ZERO
	
	use_item()
	
	var target_velocity = movement_speed*movement_direction
	velocity += (target_velocity - velocity) * movement_friction
	
	move_and_slide()


func interact() -> void:
	pass


func use_item() -> void:
	if Input.is_action_just_pressed("item_1"):
		item_manager.use_item(0)
	elif Input.is_action_just_pressed("item_2"):
		item_manager.use_item(1)
	elif Input.is_action_just_pressed("item_3"):
		item_manager.use_item(2)
	elif Input.is_action_just_pressed("item_4"):
		item_manager.use_item(3)


func _get_movement_direction() -> Vector2:
	var direction := Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
								Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))

	if direction.length() > 1.0:
		direction = direction.normalized()
		
	return direction


func _get_look_direction() -> Vector2:
	if Input.is_action_just_pressed("move_up"):
		return Vector2.UP
	elif Input.is_action_just_pressed("move_left"):
		return Vector2.LEFT
	elif Input.is_action_just_pressed("move_down"):
		return Vector2.DOWN
	elif Input.is_action_just_pressed("move_right"):
		return Vector2.RIGHT
	
	return look_direction


func _on_interaction_area_entered(other_area:Area2D) -> void:
	interaction_nodes.append(other_area.get_parent())

func _on_interaction_area_exited(other_area:Area2D) -> void:
	interaction_nodes.erase(other_area.get_parent())


func teleport(teleport_position:Vector2) -> void:
	global_position = teleport_position
