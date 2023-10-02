extends Node2D

signal item_picked_up

func _ready():
	add_to_group("collectibles")
	#print("Area2D _ready", $Area2D/CollisionShape2D.shape.get_extents())

func _on_Area2D_body_entered(body):
	if body.name == "PlayerBody":
		hide()
		$"/root/Sounds".play_sfx("Item")
		emit_signal("item_picked_up")
		queue_free()
