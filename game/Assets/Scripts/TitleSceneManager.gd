extends Node

export(NodePath) onready var audio_stream = get_node(audio_stream) as AudioStreamPlayer

export(PackedScene) var next_scene

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!audio_stream.playing): # end of stream going to next scene
		get_tree().change_scene_to(next_scene)
		
