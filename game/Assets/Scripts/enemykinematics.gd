extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var speed = 13000
export var punch_force = 30
var velocity = Vector2.ZERO
var screen_size # Size of the game window.
var preparing = false
var player: Node
var norm_velocity = Vector2.ZERO

func _ready():
	screen_size = get_viewport_rect().size
	
func _physics_process(delta):
	velocity =  Vector2.ZERO
	var player = get_node("/root/Arena/Player/PlayerBody")
	if player:
		var my_position = global_position
		var player_position = player.global_position
		var norm_velocity = my_position.direction_to(player_position).normalized()
		$AnimatedSprite.rotation = norm_velocity.angle() + PI/2
		$Punch.rotation = norm_velocity.angle() + PI/2
		velocity = delta * speed * norm_velocity	
	if !preparing: move_and_slide(velocity)
	
	global_position.x = clamp(global_position.x, 0, screen_size.x)
	global_position.y = clamp(global_position.y, 0, screen_size.y)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass




func _on_CloseRange_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if body.name != "PlayerBody":
		return
	preparing = true
	$Timer.start(0.5)


func _on_Timer_timeout():
	player = get_node("/root/Arena/Player/PlayerBody")
	if player && $Punch.overlaps_body(player):
		norm_velocity = global_position.direction_to(player.global_position).normalized()
		#print("roblox.oof")
		player.move_and_collide(norm_velocity * punch_force)
	preparing = false
