extends KinematicBody2D

onready var _animated_sprite = $AnimatedSprite

export (int) var speed = 300

var velocity = Vector2()
var rotation_dir = 0
var screen_size # Size of the game window.

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
