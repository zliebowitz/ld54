extends Node2D

signal hit

func _ready():
	pass

func _on_Area2D_body_entered(body):
	print("Item _on_Area2D_body_entered ", body.name)
	if body.name == "PlayerBody":
		hide()
