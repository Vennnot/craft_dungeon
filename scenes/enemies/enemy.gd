extends CharacterBody2D
class_name Enemy

enum TYPE {CHASER=0,KAMIKAZE,EXPLODES_ON_DEATH, COWARD, RANGED, ERRATIC,SUMMONER}

@export var tags : Array[TYPE] = []
