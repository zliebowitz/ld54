extends Node2D


onready var tearer_particles = $TearerParticles
onready var shover_particles = $ShoverParticles

var spawnType = 0
var enemyPusher = load("res://Assets/Scenes/Enemy.tscn")
var enemyTearer = load("res://Assets/Scenes/EnemyTearer.tscn")
var spawnTime = 1
var fadeTime = 2
var pointangle
var objective_point
var spawned = false
var particle_count = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	objective_point = get_parent()._find_point(true)
	rotation = position.angle_to_point(objective_point) - PI/2
	if spawnType == 0:
		tearer_particles.emitting = true
	else:
		shover_particles.emitting = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	spawnTime -= delta
	if spawnTime <= 0 && !spawned:
		var enemy
		#Determines if it is a Tearer or a Pusher
		if spawnType == 0:
			enemy = enemyTearer.instance()
			var enemybody = enemy.get_node("KinematicBody2D")
			get_parent().add_child(enemy)
			enemybody.connect("cut_event", get_parent().get_node("./Arena_Anchor/Area2D/ScreenPolygon"), "_on_EnemyCutter_cut_event")
			enemybody.angle = rotation
			enemybody.objective_point = objective_point
			tearer_particles.emitting = false
		else: 
			enemy = enemyPusher.instance()
			var enemybody = enemy.get_node("KinematicBody2D")
			enemybody.add_to_group("pushers")
			get_parent().add_child(enemy)
			shover_particles.emitting = false
		enemy.get_node("KinematicBody2D").position = position
		enemy.get_node("KinematicBody2D").connect("wall_impact", get_parent(), "_on_wall_impacted")
		enemy.add_to_group("enemies")
		spawned = true
		
	
	if spawned && spawnTime <= -1 * fadeTime:
		queue_free()
