extends Node2D

onready var _arrow = $Arrow

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


#func positionate_arrow(point):
#	var circle_radius=min(get_viewport().size.x, get_viewport().size.y)/2
#	_arrow.position=get_viewport().size()/2+circle_radius*(point-get_viewport().size/2).normalized()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var array_of_nodes = get_tree().get_nodes_in_group ( "collectibles" )
	print("Start of Collectibles found in World:")
	for _i in array_of_nodes:
		print(_i.name)
	print("End of Collectible found in World:")
	#var point=get_viewport().get_camera().unproject_position(_player.get_position())
	#$Player/PlayerBody.get_position_in_parent()
	#if point.x<0 or point.y<0 or point.x>get_viewport().size.x or point.y>get_viewport().size.y:
	#	_arrow.show() 
	#	positionate_arrow(point)
	#	_arrow.look_at(point)


