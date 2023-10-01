extends KinematicBody2D

signal OnBeginKick
signal OnEndKick


var velocity = Vector2.ZERO
var screen_size # Size of the game window.
var charging = false
var frametime = 0
var flyingTime = 0
var PrevVelocity = Vector2.ONE

const max_speed = 8
const accel = 2000
const friction = 80



# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	add_to_group("KickableButton")
	

### Object is stationary except for when the player kicks it. 
func _physics_process(delta):
	# We just started getting kicked
	if PrevVelocity == Vector2.ZERO && velocity != Vector2.ZERO: 
		emit_signal("OnBeginKick")
		
	if velocity.length() > max_speed:
		PrevVelocity = velocity
		velocity -= velocity.normalized() * ((velocity.length() / max_speed) * friction * delta)
	elif velocity.length() > (friction * delta):
		PrevVelocity = velocity
		velocity -= velocity.normalized() * ((friction) * delta)
	else:
		PrevVelocity = velocity
		velocity = Vector2.ZERO
		# we just landed from being kicked
		if PrevVelocity != Vector2.ZERO: 
			emit_signal("OnEndKick")
			
	move_and_slide(velocity)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if frametime < 10: frametime += 1
	if flyingTime > 0: 	flyingTime -= 1
