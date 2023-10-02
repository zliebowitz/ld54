extends Node


export var song = "BGM"


# Called when the node enters the scene tree for the first time.
func _ready():
	$"/root/Sounds".play_music(song)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
