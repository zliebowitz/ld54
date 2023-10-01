extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var speed = 10000
onready var player = get_node("../../Player/PlayerBody")
onready var animatedSprite = $AnimatedSprite
onready var backParticles = $BackParticles
onready var frontParticles = $FrontParticles
onready var raycast = get_node("WallRayCast")

var velocity = Vector2.ZERO
var screen_size # Size of the game window.
var charging = false
var rng = RandomNumberGenerator.new()
var angle: float
var animationTimer = -1
var frametime = 0
var flyingTime = 0
var objective_point


const max_speed = 8
const accel = 2000
const friction = 80


signal cut_event(angle, originPoint)
signal hit_player
signal wall_impact(wall, body, hit_speed)

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	rng.randomize()
	animatedSprite.play("default")
	add_to_group("enemy")
	self.connect("hit_player", player, "_on_hit_player")
	

func _physics_process(delta):
	var my_position = get_node("../../Arena_Anchor").to_local(position)
	if !charging:
		var norm_velocity = my_position.direction_to(objective_point).normalized()
		rotation =  norm_velocity.angle() + PI/2
		
		velocity += norm_velocity * accel * delta
	
	if charging:
		rotation = lerp_angle(rotation, -(angle + PI/2), .3)
	
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
	
	if my_position.distance_to(objective_point) < 5:
		_on_reaching_objective()
	
	#global_position.x = clamp(global_position.x, 0, screen_size.x)
	#global_position.y = clamp(global_position.y, 0, screen_size.y)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if frametime < 10: frametime += 1
	if flyingTime > 0: flyingTime -= 1
	if animationTimer >= 0:
		animationTimer += delta
		if animationTimer >= 0.5:
			animatedSprite.play("charge")
			backParticles.emitting = true
			backParticles.initial_velocity = ((animationTimer - 0.5)/ 2.5) * 500
			frontParticles.emitting = true
			frontParticles.initial_velocity = ((animationTimer - 0.5)/ 2.5) * -500

func _on_reaching_objective():
	animatedSprite.play("attack")
	charging = true
	#rotation = -(angle + PI/2)
	$Timer.start(3)
	animationTimer = 0
	#if player && ($BackParticles.overlaps_body(player) || $FrontParticles.overlaps_body(player)):
	emit_signal("hit_player")
	return


func _on_Timer_timeout():
	emit_signal("cut_event", angle, position)
	get_parent().queue_free()



