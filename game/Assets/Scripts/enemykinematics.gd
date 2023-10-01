extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var speed = 13000
export var punch_force = 30
onready var player = get_node("../../Player/PlayerBody")
onready var raycast = get_node("WallRayCast")
var velocity = Vector2.ZERO
var screen_size # Size of the game window.
var preparing = false
var norm_velocity = Vector2.ZERO
var frametime = 0
var flyingTime = 0

const max_speed = 8
const accel = 2000
const friction = 80

signal hit_player
signal wall_impact(wall, body, hit_speed)

func _ready():
	screen_size = get_viewport_rect().size
	add_to_group("enemy")
	self.connect("hit_player", player, "_on_hit_player")
	
func _physics_process(delta):
	if player:
		var my_position = global_position
		var player_position = player.global_position
		norm_velocity = my_position.direction_to(player_position).normalized()
		$AnimatedSprite.rotation = norm_velocity.angle() + PI/2
		$Punch.rotation = norm_velocity.angle() + PI/2
		velocity += norm_velocity * accel * delta
	#if !preparing: move_and_slide(velocity)
	
	if velocity.length() > max_speed:
		velocity -= velocity.normalized() * ((velocity.length() / max_speed) * friction * delta)
	elif velocity.length() > (friction * delta):
		velocity -= velocity.normalized() * ((friction) * delta)
	else:
		velocity = Vector2.ZERO	
	
	if flyingTime > 0:
		$WallRayCast.cast_to = (velocity * delta * 2).rotated(-rotation)
		raycast.force_raycast_update()
		#print(raycast.get_collider())
		if raycast.is_colliding():
			var impactedwall = raycast.get_collider()
			emit_signal("wall_impact", impactedwall, get_parent(), raycast.cast_to.length())
			
	else: raycast.cast_to = Vector2.ZERO
	
	move_and_slide(velocity)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if frametime < 10: frametime += 1
	if flyingTime > 0: flyingTime -= 1




func _on_CloseRange_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if body.name != "PlayerBody":
		return
	preparing = true
	$Timer.start(0.5)


func _on_Timer_timeout():
	if player && $Punch.overlaps_body(player):
		norm_velocity = global_position.direction_to(player.global_position).normalized()
		#print("roblox.oof")
		player.move_and_collide(norm_velocity * punch_force)
		emit_signal("hit_player")
	preparing = false
