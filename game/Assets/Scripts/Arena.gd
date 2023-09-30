extends Node2D


var arena
var rng = RandomNumberGenerator.new()
var enemyPusher = load("res://Assets/Scenes/Enemy.tscn")
var enemyTearer = load("res://Assets/Scenes/EnemyTearer.tscn")
var tearerRatio = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	#$EnemyCutter/KinematicBody2D.connect("cut_event", $Area2D/ScreenPolygon, "_on_EnemyCutter_cut_event")
	arena = $"Arena_Anchor/Area2D/ScreenPolygon"
	$Timer.start(3)
	
func _spawn_enemies(point: Vector2):
	var enemy
	#Determines if it is a Tearer or a Pusher
	if (rng.randf() < tearerRatio):
		enemy = enemyTearer.instance()
		add_child(enemy)
		enemy.get_node("KinematicBody2D").connect("cut_event", $Arena_Anchor/Area2D/ScreenPolygon, "_on_EnemyCutter_cut_event")
	else: 
		enemy = enemyPusher.instance()
		add_child(enemy)
	enemy.add_to_group("Enemies")
	enemy.get_node("KinematicBody2D").position = point

func _find_point():
	var tempArena = arena.duplicate()
	var rNum = rng.randi_range(0, tempArena.polygon.size()-2)
	var a1 = tempArena.polygon[rNum]
	var a2 = tempArena.polygon[rNum+1]
	tempArena.polygon.remove(rNum)
	rNum = rng.randi_range(0, tempArena.polygon.size()-2)
	var b1 = tempArena.polygon[rNum]
	var b2 = tempArena.polygon[rNum+1]
	var randA = rng.randf_range(0, 1)
	var randB = rng.randf_range(0, 1)
	var randC = rng.randf_range(0, 1)

	var p1 = a1 + ((a2 - a1) * randA)
	var p2 = b1 + ((b2 - b1) * randB)
	return p1 + ((p2 - p1) * randC)

func _on_Timer_timeout():
	var randomPoint = _find_point()
	_spawn_enemies(randomPoint)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var baddies = get_tree().get_nodes_in_group("Enemies")
	#for enemy in baddies:
	#if !Geometry.is_point_in_pdolygon(enemy.position, )
	#pass
