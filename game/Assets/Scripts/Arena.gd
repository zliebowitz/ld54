extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$EnemyCutter/KinematicBody2D.connect("cut_event", $Area2D/ScreenPolygon, "_on_EnemyCutter_cut_event")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
