###
#  Kickable Button works like this:
# 	Label's text gets set on begin play. You can set in editor of the kinematic body 2D script.
#   If you want to programmatically do it, set via SetLabelText(TEXT) 
#   you could do this via signals if you want to do that... 


extends Node

export var LabelText = "Text"
onready var label = $KinematicBody2D/Label

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	SetLabelText(LabelText)
		
		
func SetLabelText(text):
	if(label):
		label.text = text
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
