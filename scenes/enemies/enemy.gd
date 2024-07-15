extends CharacterBody2D
class_name Enemy


enum TYPE {CHASER=0,KAMIKAZE,EXPLODES_ON_DEATH, COWARD, RANGED, ERRATIC,SUMMONER}
enum REGION {ALL=0}

@export var tags : Array[TYPE] = []
@export var region_tags: Array[REGION] = []
