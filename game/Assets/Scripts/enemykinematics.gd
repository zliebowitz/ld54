extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var collision = $CollisionShape2D
onready var bump_particles = $BumpParticles
onready var big_bump_particles = $BigBumpParticles
onready var upper_particles = $UpperParticles
onready var lower_particles = $LowerParticles
onready var sprite = $AnimatedSprite

export var speed = 12000
export var punch_force = 100
export var boid_force = 200
export var charge_force = 3000
export var charge_knockback = 1000
export var charge_chance = 0.4
onready var player = get_node("../../Player/PlayerBody")
onready var raycast = get_node("WallRayCast")
var velocity = Vector2.ZERO
var screen_size # Size of the game window.
var preparing = false
var charging = 0
var charge_cooldown = 20
var charge_at_time = 0 			#How long we stay actually charging at the player
var charge_vector = Vector2.ZERO
var norm_velocity = Vector2.ZERO
var frametime = 0
var flyingTime = 0
var heavy_kicked = false
var rng = RandomNumberGenerator.new()
var bump_emitting = 0
var big_bump_emitting = 0

const max_speed = 8
const accel = 2000
const friction = 100
const default_color = Color(40.0/255.0,192.0/255.0,116.0/255.0)
const charging_time = 30

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
			if !heavy_kicked:
				emit_signal("wall_impact", impactedwall, get_parent(), 500)
			else:
				emit_signal("wall_impact", impactedwall, get_parent(), 1000)
			var scene = load("res://Assets/Scenes/EnemyKilled.tscn")
			var enemy_killed = scene.instance()
			enemy_killed.global_position = global_position
			enemy_killed.rotation = $WallRayCast.get_collision_normal().angle()
			get_parent().get_parent().add_child(enemy_killed)
				
			
	#When the windup ends and it charges you
	if preparing && charging == 0:
		velocity += charge_vector * charge_force
		charge_at_time = 30
		preparing = false
			
	else: raycast.cast_to = Vector2.ZERO
	
	#If not currently charging at player
	if charge_at_time == 0:
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
		var chargeable = $ChargeRange.get_overlapping_bodies()
		for body in chargeable:
			if body.name == "PlayerBody":
				_on_ChargeRange_body_shape_entered(0, body, 0, 0)
			
	
	if charge_at_time > 0:
		$ChargeRayCast.cast_to = (velocity * delta).rotated(-rotation)
		$ChargeRayCast.force_raycast_update()
		if $ChargeRayCast.is_colliding():
			big_bump_emitting = big_bump_particles.lifetime * .5
			var playerbody = raycast.get_collider()
			norm_velocity = global_position.direction_to(player.global_position).normalized()
			player.velocity += norm_velocity * charge_knockback
			charge_at_time = 0
	
	move_and_slide(velocity)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	bump_emitting -= delta
	bump_particles.emitting = (bump_emitting >= 0)
	big_bump_emitting -= delta
	big_bump_particles.emitting = (big_bump_emitting >= 0)
	
	if charging > 0:
		var shade = (charging_time - charging)
		var newParticleColor = Color((default_color.r + shade*6)/255.0, (default_color.g - shade)/255.0, (default_color.b - shade)/255.0)
		var newModulateColor = Color(1 + shade/15.0, (255 - shade * 5)/255.0, (255 - shade * 5)/255.0)
		#upper_particles.color = newParticleColor
		#lower_particles.color = newParticleColor
		sprite.modulate = newModulateColor
	else:
		sprite.modulate = Color(1, 1, 1)
		upper_particles.color = default_color
		lower_particles.color = default_color
		
	
	if frametime < 10: frametime += 1
	if flyingTime > 0: flyingTime -= 1
	if charging > 0: charging -= 1
	if charge_at_time > 0: charge_at_time -= 1
	if charge_cooldown > 0: charge_cooldown -= 1



func _on_ChargeRange_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.name == "PlayerBody" && charge_cooldown == 0:
		charge_cooldown = 100
		if rng.randf() < charge_chance:
			preparing = true
			charging = charging_time
			charge_vector = global_position.direction_to(player.global_position).normalized()
	pass # Replace with function body.
