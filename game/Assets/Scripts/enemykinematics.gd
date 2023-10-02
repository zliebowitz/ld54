extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var collision = $CollisionShape2D
onready var bump_particles = $BumpParticles

export var speed = 12000
export var punch_force = 100
export var boid_force = 200
export var charge_force = 3000
export var charge_chance = .2
onready var player = get_node("../../Player/PlayerBody")
onready var raycast = get_node("WallRayCast")
var velocity = Vector2.ZERO
var screen_size # Size of the game window.
var preparing = false
var charging = 0
var charge_cooldown = 0
var charge_vector = Vector2.ZERO
var norm_velocity = Vector2.ZERO
var frametime = 0
var flyingTime = 0
var heavy_kicked = false
var rng = RandomNumberGenerator.new()
var bump_emitting = 0

const max_speed = 8
const accel = 2000
const friction = 100

signal hit_player
signal wall_impact(wall, body, hit_speed)

func _ready():
	screen_size = get_viewport_rect().size
	rng.randomize()
	add_to_group("enemy")
	self.connect("hit_player", player, "_on_hit_player")
	
func _physics_process(delta):
	if !heavy_kicked:
		if player && flyingTime == 0 && !charging:
			var my_position = global_position
			var player_position = player.global_position
			norm_velocity = my_position.direction_to(player_position).normalized()
			$AnimatedSprite.rotation = norm_velocity.angle() + PI/2
			velocity += norm_velocity * accel * delta
		#if !preparing: move_and_slide(velocity)
		
		if velocity.length() > max_speed:
			velocity -= velocity.normalized() * ((velocity.length() / max_speed) * friction * delta)
		elif velocity.length() > (friction * delta):
			velocity -= velocity.normalized() * ((friction) * delta)
		else:
			velocity = Vector2.ZERO	
	else:
		pass
	
	if flyingTime > 0:
		charging = 0
		preparing = false
		$WallRayCast.cast_to = (velocity * delta * 2).rotated(-rotation)
		raycast.force_raycast_update()
		#print(raycast.get_collider())
		if raycast.is_colliding():
			var impactedwall = raycast.get_collider()
			emit_signal("wall_impact", impactedwall, get_parent(), raycast.cast_to.length())
			var scene = load("res://Assets/Scenes/EnemyKilled.tscn")
			var screen_tear = scene.instance()
			screen_tear.global_position = global_position
			screen_tear.rotation = $WallRayCast.get_collision_normal().angle()
			get_parent().get_parent().add_child(screen_tear)
			
	if preparing && charging == 0:
		velocity += charge_vector * charge_force
		preparing = false
			
	else: raycast.cast_to = Vector2.ZERO
	
	var touching = $CloseRange.get_overlapping_bodies()
	for body in touching:
		if body.name == "PlayerBody":
			bump_emitting = bump_particles.lifetime * .5
			norm_velocity = global_position.direction_to(player.global_position).normalized()
			player.velocity += norm_velocity * punch_force
			emit_signal("hit_player")
		
		if body.is_in_group("pushers"):
			var closeness = global_position.distance_to(body.global_position)
			norm_velocity = global_position.direction_to(body.global_position).normalized()
			body.velocity += norm_velocity * boid_force * (23 / (closeness + .01))
			velocity -= norm_velocity * boid_force * (23 / (closeness + .01))
	
	move_and_slide(velocity)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	bump_emitting -= delta
	bump_particles.emitting = (bump_emitting >= 0)
	
	
	if frametime < 10: frametime += 1
	if flyingTime > 0: flyingTime -= 1
	if charging > 0: charging -= 1



#The Punch function
#func _on_CloseRange_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
#	if body.name == "PlayerBody":
#		norm_velocity = global_position.direction_to(player.global_position).normalized()
#		player.velocity += norm_velocity * punch_force
#		emit_signal("hit_player")
#	if body.is_in_group("pushers"):
#		var closeness = global_position.distance_to(body.global_position)
#		norm_velocity = global_position.direction_to(body.global_position).normalized()
#		body.velocity += norm_velocity * boid_force * (23 / (closeness + .01))
#		velocity -= norm_velocity * boid_force * (23 / (closeness + .01))


#func _on_Timer_timeout():
#	pass
#	if player && $Punch.overlaps_body(player):
#		norm_velocity = global_position.direction_to(player.global_position).normalized()
#		#print("roblox.oof")
#		player.move_and_collide(norm_velocity * punch_force)
#		emit_signal("hit_player")
#	preparing = false


func _on_ChargeRange_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.name == "PlayerBody" && charge_cooldown == 0 && rng.randf() < charge_chance:
		preparing = true
		charging = 30
		charge_cooldown = 200
		charge_vector = global_position.direction_to(player.global_position).normalized()
	pass # Replace with function body.
