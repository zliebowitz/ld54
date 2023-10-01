extends Node2D


onready var arena = get_node("Arena_Anchor/Area2D/ScreenPolygon")
var rng = RandomNumberGenerator.new()
var enemyPusher = load("res://Assets/Scenes/Enemy.tscn")
var enemyTearer = load("res://Assets/Scenes/EnemyTearer.tscn")
var item01        =  load("res://Assets/Scenes/Item.tscn")
var tearerRatio = 1
var framelock = false

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
	#enemy.get_node("KinematicBody2D").position = point
	enemy.get_node("KinematicBody2D").position = $Arena_Anchor.to_global(point)
	#print(enemy.get_node("KinematicBody2D"))
	enemy.add_to_group("enemies")

func _spawn_item(point: Vector2):
	var count = 0
	for child in self.get_children():
		if "Item" in child.name:
			if child.pickedUp:
				remove_child(child)
			else:
				count+=1
	if(count > 2):
		return
	var item
	item = item01.instance()
	add_child(item)
	item.position = point
	

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
	print(randomPoint)
	_spawn_enemies(randomPoint)
	
	var randomPointItem = _find_point()
	_spawn_item(randomPointItem)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if framelock:
		framelock = false
		return
	var baddies = get_tree().get_nodes_in_group("enemies")
	for hitlist in baddies:			#See if any enemies are outsize the zone. If so, kill them
		var body = hitlist.get_node("KinematicBody2D")   #The actual body of the enemy
		if !Geometry.is_point_in_polygon(arena.to_local(body.position), arena.polygon) && body.frametime > 9:
			#print(hitlist.get_node("../Arena_Anchor/Area2D/ScreenPolygon").to_local(body.position))
			hitlist.queue_free()
			#print(hitlist.get_node("KinematicBody2D").position)
			
	#pass
	
	#originPoint = $"../..".to_local(originPoint)


func _on_framelock(status):
	framelock = status
