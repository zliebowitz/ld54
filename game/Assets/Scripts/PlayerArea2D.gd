extends Area2D

var playerObjects = []
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Area2D_body_entered(body):
	print("Player _on_Area2D_body_entered", body.name)
	if body.name != "KinematicBody2D":
		return
	playerObjects.append(body)
	
	if(playerObjects.size() > 3):
		playerObjects.pop_back()
	
	
