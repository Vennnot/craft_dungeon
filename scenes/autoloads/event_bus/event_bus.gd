extends Node

signal item_mouse_entered(item)

func emit_item_mouse_entered(item:Item) -> void:
	item_mouse_entered.emit(item)

signal item_mouse_exited

func emit_item_mouse_exited() -> void:
	item_mouse_exited.emit()

# ---------------------------------

var _observers: Dictionary = {}

func subscribe(event_name: String, callback: Callable):
	if not event_name in _observers:
		_observers[event_name] = []
	
	_observers[event_name].append(callback)


func unsubscribe(event_name: String, callback: Callable):
	if not event_name in _observers:
		return
	
	_observers.erase(callback)

func publish(event_name: String):
	if not event_name in _observers:
		return
	
	for callable: Callable in _observers[event_name]:
		callable.call()
