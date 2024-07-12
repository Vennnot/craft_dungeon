extends Resource
class_name RoomLayout


@export var file_path : String

#0 to 2, 2 being hard
@export var difficulty : int = -1

@export var type : Room.TYPE = Room.TYPE.DEFAULT

@export var exits : Dictionary = {}

@export var cells : Dictionary = {}
