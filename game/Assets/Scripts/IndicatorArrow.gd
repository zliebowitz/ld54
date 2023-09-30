extends Node2D

export (Texture) var texture setget _set_texture

func _set_texture(value):
	# if the texture variable is modified externally,
	# this callback is called.
	texture = value #texture was changed
	update() # update the node

var viewport_offset = 20
onready var _arrow = $Arrow

var player_position = Vector2(0,0)
var item_position = Vector2(0,0)
var indicator_location = Vector2(0,0)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


#func positionate_arrow(point):
#	var circle_radius=min(get_viewport().size.x, get_viewport().size.y)/2
#	_arrow.position=get_viewport().size()/2+circle_radius*(point-get_viewport().size/2).normalized()

func is_position_in_viewport(position: Vector2):
	return get_viewport_rect().has_point(position);
	
func _draw():
	#draw_texture(texture, indicator_location)
	draw_texture(texture, player_position)
	draw_line(player_position, item_position, Color.coral, 3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player = get_node("/root/Arena/Player/PlayerBody")
	if !player:
		return
		
	print("PLAYER")
	print(player.global_position)
	var p1 = player.global_position
	player_position = player.global_position
	
	var array_of_nodes = get_tree().get_nodes_in_group ( "collectibles" )
	for _item in array_of_nodes:
		if(!is_position_in_viewport(_item.global_position)):
			item_position = _item.global_position
			var p2 = _item.global_position
			var slope = (p1.y - p2.y)/(p1.x-p2.x)
			var y_intercept = p2.y / (p2.x*slope)
			var p3 = Vector2(0,0)
			p3.x = get_viewport_rect().end.x - viewport_offset
			p3.y = p3.x * slope + y_intercept
			indicator_location = p3
			update()
			
			print(p3)
			#var slope = _item.position.y - 
			#need to create point at this here
			print("NEED TO POINT TO THIS")		
			print(_item.name)
			print(_item.global_position)

	
	
	#var point=get_viewport().get_camera().unproject_position(_player.get_position())
	#$Player/PlayerBody.get_position_in_parent()
	#if point.x<0 or point.y<0 or point.x>get_viewport().size.x or point.y>get_viewport().size.y:
	#	_arrow.show() 
	#	positionate_arrow(point)
	#	_arrow.look_at(point)


