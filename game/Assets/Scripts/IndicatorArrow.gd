extends Node2D

export(NodePath) onready var player_node = get_node(player_node) as Node
export(NodePath) onready var camera2D = get_node(camera2D) as Camera2D
export var tracking_group = "collectibles"
export var draw_sprite_indicator = true
export var sprite_origin = Vector2(0,0)
export var draw_line = true
export var line_width = 1
export var line_color = Color.coral
export var draw_circle = true
export var circle_radius = 5
export var circle_color = Color.coral
export var viewport_offset = 20
export var max_to_show = 2


export (Texture) var sprite_indicator setget _set_sprite_indicator

func _set_sprite_indicator(value):
	# if the texture variable is modified externally,
	# this callback is called.
	sprite_indicator = value #texture was changed
	update() # update the node


var player_position = Vector2(0,0)
var item_positions = []
var indicator_locations = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_corrected_viewport_rect():
	var center = camera2D.get_camera_screen_center()
	
	var vprect = camera2D.get_viewport_rect() 
	vprect.end.x = vprect.end.x * camera2D.get_zoom().x
	vprect.end.y = vprect.end.y * camera2D.get_zoom().y
	
	var rect : Rect2
	rect.position.x = center.x - (vprect.size.x/2.0)
	rect.end.x = center.x + (vprect.size.x/2.0)
	rect.position.y = center.y - (vprect.size.y/2.0)
	rect.end.y = center.y + (vprect.size.y/2.0)
	
	return rect

func is_position_in_viewport(position: Vector2):
	return get_corrected_viewport_rect().has_point(position);
	
func _draw():
	if(draw_circle):
		for point in indicator_locations:
			draw_circle(point, circle_radius, circle_color)
	if(draw_line):
		for point in item_positions:
			draw_line(player_position, point, line_color, line_width)
	if(draw_sprite_indicator):
		var i = 0
		for point in indicator_locations:
			var angle_to_item = player_position.angle_to_point(point)+PI
			var distance_to_item = player_position.distance_to(point)
			var scale = min(5, max(1, 500 / distance_to_item)) 
			draw_set_transform(point, angle_to_item, scale * Vector2.ONE)
			draw_texture(sprite_indicator, -sprite_origin)
			draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
			i += 1

	
class PointSorter:
	var player_position : Vector2
	
	func _init(player_pos):
		player_position = player_pos
		
	func compare(a : Vector2, b : Vector2):
		var a_dist_squared = player_position.distance_squared_to(a)
		var b_dist_squared = player_position.distance_squared_to(b)
		return a_dist_squared < b_dist_squared

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if !player_node:
		return
		
	player_position = player_node.global_position
	
	item_positions.clear()
	indicator_locations.clear()
	var array_of_nodes = get_tree().get_nodes_in_group ( tracking_group )
	for _item in array_of_nodes:
		if(!is_position_in_viewport(_item.global_position)):
			item_positions.append(_item.global_position)

	if item_positions.size() > max_to_show:
		var sorter = PointSorter.new(player_position)
		item_positions.sort_custom(sorter, "compare")
		item_positions = item_positions.slice(0, max_to_show)

	for p2 in item_positions:	
			var deltay = p2.y - player_position.y
			var deltax = p2.x - player_position.x
			var slope = 0.0		
			if(p2.x == player_position.x):
				slope = 999
			else:
				slope = (deltay)/(deltax)
			var y_intercept = p2.y - (p2.x*slope)
			
			var p3 = Vector2(0,0)
			var p4 = Vector2(0,0)
			if(deltax >= 0):
				p3.x = get_corrected_viewport_rect().end.x - viewport_offset
				p3.y = p3.x * slope + y_intercept
			else:
				p3.x = get_corrected_viewport_rect().position.x + viewport_offset
				p3.y = p3.x * slope + y_intercept
			
			if(deltay >= 0):
				p4.y = get_corrected_viewport_rect().end.y - viewport_offset
				p4.x = (p4.y - y_intercept)/slope
			else:
				p4.y = get_corrected_viewport_rect().position.y + viewport_offset
				p4.x = (p4.y - y_intercept)/slope
			
			if(player_position.distance_to(p4) <= player_position.distance_to(p3)):
				indicator_locations.append(p4)
			else:
				indicator_locations.append(p3)
			
	update()
