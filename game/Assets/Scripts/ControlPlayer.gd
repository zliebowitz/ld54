extends KinematicBody2D

onready var _animated_sprite = $AnimatedSprite
onready var _player_kick = $PlayerKick
onready var _timer= $CanKickAgainTimer

export (int) var speed = 100

var velocity = Vector2()
var rotation_dir = 0
var screen_size # Size of the game window.

export var kick_power = 500


func _ready():
	screen_size = get_viewport_rect().size

	
func get_input():
	velocity = Vector2()
	var input_pressed = false
	
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
		input_pressed = true

	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
		input_pressed = true

	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
		input_pressed = true

	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
		input_pressed = true
		
	if Input.is_action_just_pressed("attack") && _timer.is_stopped():
		print("kick")
		_player_kick.rotation = velocity.angle()
		# documentations uggests that the below may use lst fram's velocity
		var bodies =  _player_kick.get_overlapping_bodies()
		for body in bodies:
			if body.find_parent("Enemy*") != null || body.find_parent("EnemyCutter*") != null:
				body.move_and_collide((body.global_position - global_position).normalized() * kick_power)
		_timer.start()
	
		
	velocity = velocity.normalized() * speed
	if input_pressed:
		rotation_dir = velocity.angle() + PI/2
		
	

func _physics_process(delta):
	get_input()
	velocity = move_and_slide(velocity)
	rotation = rotation_dir
	
	global_position.x = clamp(global_position.x, 0, screen_size.x)
	global_position.y = clamp(global_position.y, 0, screen_size.y)
	
func _process(delta):
	if velocity == Vector2.ZERO:
		 _animated_sprite.play("idle")
	else:
		_animated_sprite.play("walk")
