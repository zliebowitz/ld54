extends Node2D

var pickedUp = false

func _ready():
	add_to_group("collectibles")
	$Area2D.connect("body_entered", self, "_on_Area2D_body_entered")
	#print("Area2D _ready", $Area2D/CollisionShape2D.shape.get_extents())

func _on_Area2D_body_entered(body):
	print("Item _on_Area2D_body_entered ", body.name)
	if body.name == "PlayerBody":
		hide()
		pickedUp = true
