extends Node2D

export var bSpawnObjects = true

onready var arena = get_node("Arena/Arena_Anchor")
var rng = RandomNumberGenerator.new()
var item01 = load("res://Assets/Scenes/Item.tscn")
var speed = 1
var friction = 80
var viewfriction = 0.2
var cameraspeed = 10
var acceleration = 0.1
var input_velocity = Vector2.ZERO
var velocity = Vector2.ZERO
var viewvelocity = Vector2.ZERO
var items_to_spawn = 14
var min_x = 9999999
var max_x = -9999999
var min_y = 9999999
var max_y = -9999999

const max_speed = 12


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	if name == "World": $View_Anchor/KickableCounter/KinematicBody2D/ObjectCounter/Counter.text = str(Global.items_collected)
	$Arena/Player/PlayerBody.connect("wallnudge", self, "_on_Arena_wallnudge")
	if name == "World": $Item.connect("item_picked_up", self, "on_item_pick_up")
	
	var polygon : Polygon2D = get_node("Polygon2D")
	var points : PoolVector2Array = polygon.polygon
	for point in points:
		min_x = min(min_x, point.x)
		max_x = max(max_x, point.x)
		min_y = min(min_y, point.y)
		max_y = max(max_y, point.y)
	
	if (bSpawnObjects):
		for i in range(items_to_spawn):
			_spawn_item()

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

	"""
	# If there's input, accelerate to the input velocity
	if input_velocity.length() > 0:
		velocity = velocity.linear_interpolate(input_velocity, acceleration)
		viewvelocity = viewvelocity.linear_interpolate(input_velocity, acceleration)
	else:
		# If there's no input, slow down to (0, 0)
		velocity = velocity.linear_interpolate(Vector2.ZERO, friction)
		viewvelocity = viewvelocity.linear_interpolate(Vector2.ZERO, viewfriction)"""
	
	velocity += input_velocity
	
	if velocity.length() > max_speed:
		velocity -= velocity.normalized() * ((velocity.length() / max_speed) * friction * delta)
	elif velocity.length() > (friction * delta):
		velocity -= velocity.normalized() * ((friction) * delta)
	else:
		velocity = Vector2.ZERO
		
		
	input_velocity = Vector2.ZERO
	velocity = arena.move_and_slide(velocity)
	$View_Anchor.position = lerp($View_Anchor.position, $Arena/Arena_Anchor.position, cameraspeed * delta)
	#viewvelocity = $View_Anchor.move_and_slide(viewvelocity)
#	pass

func _spawn_item():
	var item = item01.instance()
	add_child(item)
	item.position = Vector2(rng.randi_range(min_x, max_x), rng.randi_range(min_y, max_y))
	item.connect("item_picked_up", self, "on_item_pick_up")
	
func on_item_pick_up():
	Global.items_collected += 1
	$View_Anchor/KickableCounter/KinematicBody2D/ObjectCounter/Counter.text = str(Global.items_collected)
	if(Global.items_collected >= Global.item_win_count):
		get_tree().change_scene("res://Assets/Scenes/CutScene.tscn")
		$"/root/Sounds".stop_music()

func _on_Arena_wallnudge(direction, hit_speed):
	print(hit_speed)
	print(speed)
	var right = Vector2.RIGHT
	input_velocity = right.rotated(direction) * speed * hit_speed
	print(input_velocity)
