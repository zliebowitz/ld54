extends Node2D

signal picked_up

func _ready():
	add_to_group("collectibles")
	#$Area2D.connect("body_entered", self, "_on_Area2D_body_entered")
	#print("Area2D _ready", $Area2D/CollisionShape2D.shape.get_extents())

func _on_Area2D_body_entered(body):
	if body.name == "PlayerBody":
		hide()
		emit_signal("picked_up")
		queue_free()
