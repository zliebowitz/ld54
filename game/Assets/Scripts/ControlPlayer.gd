extends KinematicBody2D

export (int) var speed = 300

var velocity = Vector2()
var rotation_dir = 0
var screen_size # Size of the game window.

func _ready():
	screen_size = get_viewport_rect().size
	position = Vector2(512, 300)
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
	
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
