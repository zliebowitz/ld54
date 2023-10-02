extends Node2D

export var bSpawnEnemies = true


onready var arena = get_node("Arena_Anchor/Area2D/ScreenPolygon")
var rng = RandomNumberGenerator.new()
var enemyPusher = load("res://Assets/Scenes/Enemy.tscn")
var enemyTearer = load("res://Assets/Scenes/EnemyTearer.tscn")
var enemySpawner= load("res://Assets/Scenes/EnemySpawner.tscn")
var wall		= load("res://Assets/Scenes/WallAreas.tscn")
var rigidwall =   load("res://Assets/Scenes/RigidWall.tscn")
var tearerRatio = .3
var framelock = false
var pointangle

signal wallnudge(direction)

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	arena = $"Arena_Anchor/Area2D/ScreenPolygon"
	$Timer.start(2)
	_on_fillwalls(arena.polygon)
	
func _spawn_enemies(point: Vector2):
	var spawner = enemySpawner.instance()
	spawner.position = $Arena_Anchor.to_global(point)
	var spawnType = 1
	if (rng.randf() < tearerRatio):
		spawnType = 0
	spawner.spawnType = spawnType
	add_child(spawner)
	
	

func _find_point(edge: bool):
	var a1
	var a2
	var b1
	var b2
	var tempArena = arena.duplicate()
	var rNum1 = rng.randi_range(0, tempArena.polygon.size()-1)
	a1 = tempArena.polygon[rNum1]
	if rNum1 == tempArena.polygon.size()-1: a2 = tempArena.polygon[0]
	else: a2 = tempArena.polygon[rNum1+1]
	
	if edge:
		b1 = a2
		b2 = tempArena.polygon[(rNum1 + 2) % tempArena.polygon.size()]
	else:
		var rNum2 = rng.randi_range(1, tempArena.polygon.size()-1)
		b1 = tempArena.polygon[(rNum1 + rNum2) % tempArena.polygon.size()]
		b2 = tempArena.polygon[(rNum1 + rNum2 + 1) % tempArena.polygon.size()]
	var randA = rng.randf_range(0, 1)
	var randB = rng.randf_range(0, 1)
	var randC = rng.randf_range(0, 1)

	var p1 = a1 + ((a2 - a1) * randA)
	var p2 = b1 + ((b2 - b1) * randB)
	
	pointangle = p1.angle_to_point(p2) + PI/2
	if pointangle < 0: pointangle += PI
	if (p1 + ((p2 - p1) * randC)).x == 956:
		print(p1)
	return p1 + ((p2 - p1) * randC)

#Also sets difficulty
func _on_Timer_timeout():
	var randomPoint
	$Timer.start(2 - (Global.items_collected / 5))
	if bSpawnEnemies && Global.items_collected > 0:
		var number_to_spawn = rng.randi_range(1, (Global.items_collected/2) + 1)
		print(number_to_spawn)
		for i in number_to_spawn:
			randomPoint = _find_point(false)
			_spawn_enemies(randomPoint)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if framelock:
		framelock = false
		return
	var baddies = get_tree().get_nodes_in_group("enemies")
	for hitlist in baddies:			#See if any enemies are outsize the zone. If so, kill them
		var body = hitlist.get_node("KinematicBody2D")   #The actual body of the enemy
		if !Geometry.is_point_in_polygon(arena.to_local(body.position), arena.polygon) && body.frametime > 9:
			var scene = load("res://Assets/Scenes/EnemyKilledFallOff.tscn")
			var enemy_killed = scene.instance()
			enemy_killed.global_position = body.global_position
			add_child(enemy_killed)
			hitlist.queue_free()
	#Check for death
	if !Geometry.is_point_in_polygon(arena.to_local($Player/PlayerBody.position), arena.polygon):
		#print("Thou art dead")
		get_tree().change_scene("res://Assets/Scenes/GameLevels/EndGame.tscn")
	
func _on_framelock(status):
	framelock = status
	
#Creates separate walls for the arena. Called every time a cut happens
func _on_fillwalls(shape):
	var area = get_node("Arena_Anchor")
	for n in area.get_children():
		if n.name != "Area2D" && n.name != "Anchor_Collision": area.remove_child(n)
	for i in shape.size():
		var wallarea = wall.instance()
		var rigidwallarea = rigidwall.instance()
		var segment = wallarea.get_child(0)
		var segment2 = rigidwallarea.get_child(0)
		segment.shape = SegmentShape2D.new()
		segment.shape.a = shape[i-1]
		segment2.shape = SegmentShape2D.new()
		segment2.shape.a = shape[i-1]
		if i == shape.size():
			segment.shape.b = shape[0]
			segment2.shape.b = shape[0]
		else: 
			segment.shape.b = shape[i]
			segment2.shape.b = shape[i]
		area.add_child(wallarea)
		area.add_child(rigidwallarea)
	#print(area.get_children())
		#wallarea.connect("wall_impact", self, "_on_wall_impacted")
	#print(area.get_children())
	
func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)

func _on_wall_impacted(hitwall, body, hitspeed):
	var normal = hitwall.get_child(0).shape.a.angle_to_point(hitwall.get_child(0).shape.b) + PI/2
	emit_signal("wallnudge", normal, hitspeed)
	body.queue_free()
