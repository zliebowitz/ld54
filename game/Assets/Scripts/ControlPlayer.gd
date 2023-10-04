extends KinematicBody2D

onready var _animated_sprite = $AnimatedSprite
onready var _kick_sprite = $KickAnimation
onready var _player_kick = $PlayerKick
onready var _player_heavy_kick = $PlayerHeavyKick
onready var _timer= $CanKickAgainTimer
onready var _heavy_kick_particles = $HeavyKickParticles

export (int) var speed = 100
export var kick_power = 2000
export var collision_frames = 60 	#Number of frames that a kicked enemy can impact a wall
export var heavy_kick_charge = 0
export var heavy_kick_screen_movement = 500

var input_vector = Vector2.ZERO
var aim_vector = Vector2.ZERO
var velocity = Vector2()
var heavy_kick_vector = Vector2.ZERO
var rotation_dir = 0
var screen_size # Size of the game window.
var heavy_kick = -1
var kick_right_animation = true
var knockout_timer = 0	


#var mouse_direction_has_priority = !Input.is_joy_known(0)
var mouse_direction_has_priority = false

const max_speed = 14
var accel = 2000
const friction = 80
const heavy_kick_power = 1600
const heavy_kick_speed = 1000
const heavy_kick_winddown = .2
const heavy_kick_winddown_friction = friction * 75
const knockout_time = 45			#How long you can be kicked off screen

signal wallnudge

func _ready():
	_kick_sprite.playing = true
	screen_size = get_viewport_rect().size

func _input(event):
	#if event is InputEventMouseMotion:
	#	mouse_direction_has_priority = true
	pass
	
func get_input(delta):
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	aim_vector.x = Input.get_axis("aim_left", "aim_right")
	aim_vector.y = Input.get_axis("aim_up", "aim_down")
	
	# 0.2^2
	if aim_vector.length_squared() > .04:
		mouse_direction_has_priority = false
	elif !mouse_direction_has_priority:
		aim_vector = input_vector
	
	
	# Handle direcitonal inputs
	if input_vector.length_squared() > 1.0:
		input_vector = input_vector.normalized()
	
	# Handle kick input
	if Input.is_action_pressed("attack") && _timer.is_stopped():
		if kick_right_animation:
			_kick_sprite.scale.y = -1
			kick_right_animation = false
		else:
			_kick_sprite.scale.y = 1
			kick_right_animation = true
		$"/root/Sounds".play_sfx("Kick")
		_kick_sprite.visible = true
		_kick_sprite.frame = 0
		_timer.start()
	
	if Input.is_action_just_pressed("heavy_attack") && heavy_kick < 0 && heavy_kick_charge >= 3:
		$"/root/Sounds/".play_sfx("HeavyKick")
		if mouse_direction_has_priority:
			heavy_kick_vector = global_position.direction_to(get_global_mouse_position()).normalized()
		else:
			if aim_vector.normalized() != Vector2.ZERO:
				heavy_kick_vector = aim_vector.normalized()
			else:
				heavy_kick_vector = Vector2(cos(rotation),sin(rotation))
		heavy_kick = .1 + delta
		


func _physics_process(delta):
	get_input(delta)

	#Process regular kick.
	if !_timer.is_stopped():
		var kicked_enemy = false
		# documentations uggests that the below may use lst fram's velocity
		var bodies =  _player_kick.get_overlapping_bodies()
		for body in bodies:
			if (body.is_in_group("enemy") && body.flyingTime <= collision_frames - 5) || body.is_in_group("KickableButton"):
				kicked_enemy = true
				var kick_direction
				if mouse_direction_has_priority:
					kick_direction = global_position.direction_to(get_global_mouse_position())
				else:
					kick_direction = aim_vector.normalized()
				var enemy_direction = global_position.direction_to(body.global_position) * 0.4
				var fling_vector = (kick_direction + enemy_direction).normalized()
				var angle_between = abs(kick_direction.angle_to(enemy_direction))
				var angular_ratio = 1
				if (angle_between > PI/2):
					angular_ratio = 0
				body.velocity += fling_vector * kick_power * angular_ratio
				body.flyingTime = collision_frames
		if kicked_enemy:
			if heavy_kick_charge < 3: heavy_kick_charge += 1



	# Process heavy kick.
	if heavy_kick >= heavy_kick_winddown * -1:
		var kicked_enemy = false
		var bodies =  _player_kick.get_overlapping_bodies()
		heavy_kick_charge = 0
		for body in bodies:
			if body.is_in_group("enemy") || body.is_in_group("KickableButton"):
				kicked_enemy = true
				body.velocity += heavy_kick_vector * heavy_kick_power
				body.heavy_kicked = true
				body.flyingTime = collision_frames
				body.collision.disabled = true
		if kicked_enemy:
			velocity *= .2
			heavy_kick = heavy_kick_winddown * -1
		else:
			var walls = _player_kick.get_overlapping_areas()
			for w in walls:
				if w.is_in_group("Wall"):
					var normal = w.get_child(0).shape.a.angle_to_point(w.get_child(0).shape.b) + PI/2
					emit_signal("wallnudge", normal, heavy_kick_screen_movement)
	
	velocity += input_vector * accel * delta
	if heavy_kick >= 0:
		# TODO: Replace with joystick/mouse direction 
		velocity = heavy_kick_vector * heavy_kick_speed
		heavy_kick -= delta
	elif heavy_kick < 0 && heavy_kick >= heavy_kick_winddown * -1:
		if velocity.length() > (heavy_kick_winddown_friction * delta):
			velocity -= velocity.normalized() * (heavy_kick_winddown_friction * delta)
		else:
			velocity = Vector2.ZERO
			heavy_kick = heavy_kick_winddown * -1
			
		heavy_kick -= delta
	elif velocity.length() > max_speed:
		velocity -= velocity.normalized() * ((velocity.length() / max_speed) * friction * delta)
	elif velocity.length() > (friction * delta):
		velocity -= velocity.normalized() * ((friction) * delta)
	else:
		velocity = Vector2.ZERO

	rotation = rotation_dir
	move_and_slide(velocity)
	
	#global_position.x = clamp(global_position.x, 0, screen_size.x)
	#global_position.y = clamp(global_position.y, 0, screen_size.y)
	
func _process(delta):
	
	
	var newModulateColor = Color(1 * (1 - heavy_kick_charge/4.0), 1, 1)
	if heavy_kick_charge == 3:
		newModulateColor = Color(1.8, .4, 1.8)
	#upper_particles.color = newParticleColor
	#lower_particles.color = newParticleColor
	_animated_sprite.modulate = newModulateColor
	
	
	if(mouse_direction_has_priority):
		rotation_dir = global_position.angle_to_point(get_global_mouse_position()) + PI
	else:
		if(aim_vector != Vector2.ZERO):
			rotation_dir = aim_vector.angle() 
	
	# Remove kicking sprite if not kicking.
	if _timer.is_stopped():
		_kick_sprite.visible = false
		
	if heavy_kick >= 0:
		_heavy_kick_particles.emitting = true
	else:
		_heavy_kick_particles.emitting = false
		
	if !_timer.is_stopped() || heavy_kick >= 0:
		_animated_sprite.play("kick")
	elif velocity == Vector2.ZERO:
		_animated_sprite.play("idle")
	else:
		_animated_sprite.play("walk")
	if knockout_timer > 0: knockout_timer -= 1
	else: collision_mask = 17

func _on_hit_player():
	collision_mask = 1
	knockout_timer = knockout_time
	pass
