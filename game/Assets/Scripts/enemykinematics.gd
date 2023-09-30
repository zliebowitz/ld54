extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var speed = 13000
var velocity = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	velocity =  Vector2.ZERO
	var player = get_node("/root/Screen/Player/KinematicBody2D")
	if player:
		var my_position = global_position
		var player_position = player.global_position
		var norm_velocity = my_position.direction_to(player_position).normalized()
		velocity = delta * speed * norm_velocity
	move_and_slide(velocity)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
