extends Area2D


#signal wall_impact(body, a, b)


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Wall")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


#func _on_WallAreas_body_entered(body):
	#emit_signal("wall_impact", body, $WallSegment.shape.a, $WallSegment.shape.b)
