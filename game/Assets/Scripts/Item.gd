extends Node2D

var pickedUp = false

func _ready():
	add_to_group("collectibles")

func _on_Area2D_body_entered(body):
	#print("Item _on_Area2D_body_entered ", body.name)
	if body.name == "PlayerBody":
		hide()
		pickedUp = true
