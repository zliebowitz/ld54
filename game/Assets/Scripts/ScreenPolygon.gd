extends Polygon2D

var topLeft = Vector2(0,0)
var topRight = Vector2(1000, 0)
var bottomRight = Vector2(1000,1000)
var bottomLeft = Vector2(0, 1000)
var DEBUG = false
signal framelock(status)


# Called when the node enters the scene tree for the first time.
func _ready():
	if DEBUG:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		_cut(rng.randf_range(0, PI), Vector2(500,500))


# Cuts the screen polygon, based on an angle of cut and an origin point
func _cut(angle: float, originPoint: Vector2):
	emit_signal("framelock", true)
	var player = get_node("../../../Player/PlayerBody")
	originPoint = $"../..".to_local(originPoint)
	if !Geometry.is_point_in_polygon(originPoint, polygon):
		print("The point isn't in the arena!")
		return
	
	var rightNodey = originPoint.y - ((1000-originPoint.x) * tan(angle))
	var leftNodey =  originPoint.y + (originPoint.x * tan(angle))
	
	var rightNode = Vector2(1000, rightNodey)
	var leftNode = Vector2(0, leftNodey)
	
	var cutPolygonLeft = PoolVector2Array([topLeft, topRight, rightNode, leftNode])
	var cutPolygonRight = PoolVector2Array([bottomRight, bottomLeft, leftNode, rightNode])
	
	var finalPolygonLeft = PoolVector2Array(Geometry.intersect_polygons_2d(cutPolygonLeft, polygon)[0])
	var finalPolygonRight = PoolVector2Array(Geometry.intersect_polygons_2d(cutPolygonRight, polygon)[0])
	
	#Check for which portion the player is in, and leave that one
	if player && Geometry.is_point_in_polygon(get_node("..").to_local(player.position), finalPolygonLeft):
		polygon = finalPolygonLeft
	else:
		polygon = finalPolygonRight
	#print(Geometry.is_point_in_polygon(player.position, finalPolygonLeft))
	get_node("../ScreenCollision").set_polygon(polygon)
	#print(get_node("../ScreenCollision").polygon)

func _on_EnemyCutter_cut_event(angle, origin):
	_cut(angle, origin)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
