extends KinematicBody2D

onready var _animated_sprite = $AnimatedSprite
onready var _player_kick = $PlayerKick
onready var _player_heavy_kick = $PlayerHeavyKick
onready var _timer= $CanKickAgainTimer

export (int) var speed = 100
export var kick_power = 2000
export var collision_frames = 60 	#Number of frames that a kicked enemy can impact a wall

var input_vector = Vector2.ZERO
var aim_vector = Vector2.ZERO
var velocity = Vector2()
var heavy_kick_vector = Vector2.ZERO
var rotation_dir = 0
var screen_size # Size of the game window.
var heavy_kick = -1

var mouse_direction_has_priority = true

const max_speed = 12
const accel = 2000
const friction = 80
const heavy_kick_power = 1200
const heavy_kick_speed = 1000
const heavy_kick_winddown = .2
const heavy_kick_winddown_friction = friction * 75

func _ready():
	screen_size = get_viewport_rect().size

func _input(event):
	if event is InputEventMouseMotion:
		mouse_direction_has_priority = true
	
func get_input(delta):
	
	# Handle direcitonal inputs
	input_vector.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	input_vector.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	input_vector = input_vector.normalized()
	

	aim_vector.x = int(Input.is_action_pressed("aim_right")) - int(Input.is_action_pressed("aim_left"))
	aim_vector.y = int(Input.is_action_pressed("aim_down")) - int(Input.is_action_pressed("aim_up"))
	aim_vector = aim_vector.normalized()
	if(aim_vector != Vector2.ZERO):
		mouse_direction_has_priority = false
	
	
	# Handle kick input
	if Input.is_action_just_pressed("attack") && _timer.is_stopped():
		#print("kick")
		var kicked_enemy = false
		# documentations uggests that the below may use lst fram's velocity
		var bodies =  _player_kick.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("enemy"):
				kicked_enemy = true
				var kick_direction = global_position.direction_to(get_global_mouse_position())
				var enemy_direction = global_position.direction_to(body.global_position) * 0.4
				var fling_vector = (kick_direction + enemy_direction).normalized()
				var angle_between = abs(kick_direction.angle_to(enemy_direction))
				var angular_ratio = pow(1 - (angle_between / (2*PI)),4)
				if (angle_between > PI/2):
					angular_ratio = 0
				body.velocity += fling_vector * kick_power * angular_ratio
				body.flyingTime = collision_frames
		_timer.start()
		if kicked_enemy:
			velocity += global_position.direction_to(get_global_mouse_position()) * -200
	
	if Input.is_action_just_pressed("heavy_attack") && heavy_kick < 0:
		heavy_kick_vector = global_position.direction_to(get_global_mouse_position()).normalized()
		heavy_kick = .1 + delta
		


func _physics_process(delta):
	get_input(delta)

	if heavy_kick >= heavy_kick_winddown * -1:
		#print("kick")
		var kicked_enemy = false
		# documentations uggests that the below may use lst fram's velocity
		var bodies =  _player_kick.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("enemy"):
				kicked_enemy = true
				body.velocity += heavy_kick_vector * heavy_kick_power
				body.heavy_kicked = true
				body.flyingTime = collision_frames
				body.collision.disabled = true
		if kicked_enemy:
			velocity *= -1
			heavy_kick = heavy_kick_winddown * -1
	
	
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
	if(mouse_direction_has_priority):
		rotation_dir = global_position.angle_to_point(get_global_mouse_position()) + PI
	else:
		if(aim_vector != Vector2.ZERO):
			rotation_dir = aim_vector.angle() 
	if !_timer.is_stopped():
		_animated_sprite.play("kick")
	elif velocity == Vector2.ZERO:
		_animated_sprite.play("idle")
	else:
		_animated_sprite.play("walk")

func _on_hit_player():
	pass
