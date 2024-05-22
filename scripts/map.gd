extends TileMap

signal map_ready

@export var navigation_region: NavigationRegion2D

const WALL = Vector2i(2,0)
const BG = Vector2i(1,0)

const MAX_ROOMS = 60
const MIN_ROOM_SIZE = 6
const MAX_ROOM_SIZE = 14
#const MIN_ROOM_OFFSET = -60
#const MAX_ROOM_OFFSET = 60

@onready var buildings = $Buildings
@onready var spawnarea = $Spawnarea

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(-2,2):
		for j in range(-2,2):
			generate_chunk(Vector2i(i, j))
	
	call_deferred("nav_setup")


func _process(delta):
	pass


func nav_setup():
	navigation_region.bake_navigation_polygon()
	map_ready.emit()


func generate_chunk(offset_in_chunks: Vector2i):
	print("generating chunk: ", offset_in_chunks)
	build_bg(
		Vector2i(offset_in_chunks[0] * G.CS, offset_in_chunks[1] * G.CS), 	
		Vector2i((offset_in_chunks[0] + 1) * G.CS, (offset_in_chunks[1] + 1) * G.CS))
	
	var chunk_origin_tiles = offset_in_chunks * G.CS
	# build buildings
	for i in range(MAX_ROOMS):
		var width = G.rng.randi_range(MIN_ROOM_SIZE, MAX_ROOM_SIZE)
		var height = G.rng.randi_range(MIN_ROOM_SIZE, MAX_ROOM_SIZE)
		var offset = Vector2i(
			G.rng.randi_range(0, G.CS),
			G.rng.randi_range(0, G.CS))
		build_room(width, height, chunk_origin_tiles + offset)


func build_room(width: int, height:int, offset: Vector2i):
	# create an area
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = RectangleShape2D.new()
	collision_shape.shape.size = Vector2((width + 1) * G.TS, (height + 1) * G.TS)
	var area = Area2D.new()
	area.position = Vector2(
		(offset[0] + (width / 2.0)) * G.TS,
		(offset[1] + (height / 2.0)) * G.TS
	)
	area.add_child(collision_shape)
	buildings.add_child(area)
	
	# check for overlap with existing areas
	for building in buildings.get_children():
		if area == building:
			continue

		if areas_overlap(building, area):
			area.queue_free()
			return
	
	if areas_overlap(spawnarea, area):
			area.queue_free()
			return
	
	# box of walls with empty middle
	for x in range(width):
		for y in range(height):
			if x == 0 or x == (width - 1) or y == 0 or y == (height - 1):
				set_wall(x + offset[0], y + offset[1])
				#remove_bg(x + offset[0], y + offset[1])
	
	# set doors
	remove_wall(
		[0, width - 1].pick_random() + offset[0],
		G.rng.randi_range(1, height - 2) + offset[1])
			
	remove_wall(
		G.rng.randi_range(1, width - 2) + offset[0],
		[0, height - 1].pick_random() + offset[1])

func areas_overlap(area1: Area2D, area2: Area2D) -> bool:
	var shape1 = area1.get_child(0) as CollisionShape2D
	var shape2 = area2.get_child(0) as CollisionShape2D
	
	var rect1 = shape1.shape as RectangleShape2D
	var rect2 = shape2.shape as RectangleShape2D
	
	var transform1 = area1.get_global_transform()
	var transform2 = area2.get_global_transform()
	
	var rect1_aabb = Rect2(transform1.origin, rect1.size).abs()
	var rect2_aabb = Rect2(transform2.origin, rect2.size).abs()
	return rect1_aabb.intersects(rect2_aabb)

func build_bg(top_left: Vector2i, bottom_right: Vector2i):
	for x in range(top_left[0], bottom_right[0]):
		assert (bottom_right[0] - top_left[0] == G.CS)
		for y in range(top_left[1], bottom_right[1]):
			assert (bottom_right[1] - top_left[1] == G.CS)
			set_bg(x, y)

func set_bg(x, y):
	set_cell(1, Vector2i(x, y), 0, BG)
	
func remove_bg(x, y):
	set_cell(1, Vector2i(x, y), -1, BG)

func set_wall(x, y):
	set_cell(0, Vector2i(x, y), 0, WALL)

func remove_wall(x, y):
	set_cell(0, Vector2i(x, y), -1, WALL)
