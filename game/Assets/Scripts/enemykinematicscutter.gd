extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var speed = 10000
onready var player = get_node("../../Player/PlayerBody")
onready var animatedSprite = $AnimatedSprite
onready var backParticles = $BackParticles
onready var frontParticles = $FrontParticles
var velocity = Vector2.ZERO
var screen_size # Size of the game window.
var charging = false
var rng = RandomNumberGenerator.new()
var angle: float
var animationTimer = -1

signal cut_event(angle, originPoint)

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	rng.randomize()
	$Timer.start(2)
	animatedSprite.play("default")
	

func _physics_process(delta):
	velocity =  Vector2.ZERO
	if player && !charging:
		var my_position = global_position
		var player_position = player.global_position
		var norm_velocity = my_position.direction_to(player_position).normalized()
		rotation =  norm_velocity.angle() + PI/2
		velocity = delta * speed * norm_velocity
	move_and_slide(velocity)
	
	global_position.x = clamp(global_position.x, 0, screen_size.x)
	global_position.y = clamp(global_position.y, 0, screen_size.y)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if animationTimer >= 0:
		animationTimer += delta
		if animationTimer >= 0.5:
			animatedSprite.play("charge")
			backParticles.emitting = true
			backParticles.initial_velocity = ((animationTimer - 0.5)/ 2.5) * 500
			frontParticles.emitting = true
			frontParticles.initial_velocity = ((animationTimer - 0.5)/ 2.5) * -500


func _on_Timer_timeout():
	if !charging:
		animatedSprite.play("attack")
		charging = true
		angle = rng.randf_range(0, PI)
		rotation = -(angle + PI/2)
		$Timer.start(3)
		animationTimer = 0
		return
		
	print("Cut you!")
	emit_signal("cut_event", angle, position)
	queue_free()



