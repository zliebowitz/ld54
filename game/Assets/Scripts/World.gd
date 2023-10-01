extends Node2D


onready var arena = get_node("Arena/Arena_Anchor")
var speed = 5000
var friction = 0.1
var viewfriction = 0.2
var cameraspeed = 10
var acceleration = 0.1
var input_velocity = Vector2.ZERO
var velocity = Vector2.ZERO
var viewvelocity = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):

	# Check input for "desired" velocity
	if Input.is_action_pressed("screenright"):
		input_velocity.x += 1
	if Input.is_action_pressed("screenleft"):
		input_velocity.x -= 1
	if Input.is_action_pressed("screendown"):
		input_velocity.y += 1
	if Input.is_action_pressed("screenup"):
		input_velocity.y -= 1
	input_velocity = input_velocity.normalized() * speed

	# If there's input, accelerate to the input velocity
	if input_velocity.length() > 0:
		velocity = velocity.linear_interpolate(input_velocity, acceleration)
		viewvelocity = viewvelocity.linear_interpolate(input_velocity, acceleration)
	else:
		# If there's no input, slow down to (0, 0)
		velocity = velocity.linear_interpolate(Vector2.ZERO, friction)
		viewvelocity = viewvelocity.linear_interpolate(Vector2.ZERO, viewfriction)
	input_velocity = Vector2.ZERO
	velocity = arena.move_and_slide(velocity)
	$View_Anchor.position = lerp($View_Anchor.position, $Arena/Arena_Anchor.position, cameraspeed * delta)
	#viewvelocity = $View_Anchor.move_and_slide(viewvelocity)
#	pass


func _on_Arena_wallnudge(direction, hit_speed):
	var right = Vector2.RIGHT
	input_velocity = right.rotated(direction) * speed * hit_speed
