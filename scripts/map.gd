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
@onready var player = $"../../Player"


var generated_chunk_chunkcoords = []
var buildings_generated = 0
var buildings_local = []

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for i in range(-2,2):
		for j in range(-2,2):
			generate_chunk(Vector2i(i, j))
	call_deferred("nav_setup")
	
	print("buildings generated: ", buildings.get_child_count(), "  ", buildings_generated)

func _physics_process(delta):
	
	if Engine.get_physics_frames() % 30 != 0:
		return
	
	# generate chunks if any ungenerated are near player
	var player_chunk_pos = Vector2i(
		int(player.global_position.x) / G.CS_PX,
		int(player.global_position.y) / G.CS_PX
	)
	var chunks_generated = 0
	var single_chunk_to_gen: Vector2i
	for chunk_x in range(player_chunk_pos[0]-2, player_chunk_pos[0]+2):
		for chunk_y in range(player_chunk_pos[1]-2, player_chunk_pos[1]+2):
			var candidate_chunk_coords = Vector2i(chunk_x, chunk_y)
			if not generated_chunk_chunkcoords.has(candidate_chunk_coords):
				single_chunk_to_gen = candidate_chunk_coords
				break
	if single_chunk_to_gen:
		generate_chunk(single_chunk_to_gen)
		# TODO: offset navigation baking or whatever causes the freeze (maybe it is generate_chunk() instead)
		call_deferred("nav_setup")

func nav_setup():
	print("Baking navigation...")
	navigation_region.bake_navigation_polygon()
	map_ready.emit()


# chunk_coords are in chunk coordinates - i.e. how many chunks from origin
func generate_chunk(chunk_coords: Vector2i):
	#print("generating chunk: ", chunk_coords)
	build_bg(
		Vector2i(chunk_coords[0] * G.CS, chunk_coords[1] * G.CS), 	
		Vector2i((chunk_coords[0] + 1) * G.CS, (chunk_coords[1] + 1) * G.CS))
	
	var chunk_origin_tiles = chunk_coords * G.CS
	# build buildings
	for i in range(MAX_ROOMS):
		var width = G.rng.randi_range(MIN_ROOM_SIZE, MAX_ROOM_SIZE)
		var height = G.rng.randi_range(MIN_ROOM_SIZE, MAX_ROOM_SIZE)
		var offset = Vector2i(
			G.rng.randi_range(0, G.CS),
			G.rng.randi_range(0, G.CS))
		build_room(width, height, chunk_origin_tiles + offset)
		
	generated_chunk_chunkcoords.append(chunk_coords)
	#print(generated_chunk_chunkcoords)


func build_room(width: int, height:int, offset: Vector2i):
	# create an area
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = RectangleShape2D.new()
	collision_shape.shape.size = Vector2((width + 1) * G.TS, (height + 1) * G.TS)
	var new_room_area2d = Area2D.new()
	new_room_area2d.position = Vector2(
		(offset[0] + (width / 2.0)) * G.TS,
		(offset[1] + (height / 2.0)) * G.TS
	)
	new_room_area2d.add_child(collision_shape)
	buildings.add_child(new_room_area2d)
	
	# check for overlap with existing areas
	# TODO: this is increadibly expensive, we should only check
	# for overlap within the new area
	#
	var wo = (width / 2) * G.TS
	var ho = (height / 2) * G.TS
	var areas_checked = 0
	for building in buildings_local:
		if new_room_area2d == building:
			continue
		
		# if new room overlaps with an existing building
		var bp = building.position
		var bs = building.get_child(0).shape.size
		var np = new_room_area2d.position
		if (
			bp[0] + bs[0] <= np[0] - wo or
			bp[0] - bs[0] >= np[0] + wo or
			bp[1] + bs[1] <= np[1] - ho or
			bp[1] - bs[1] >= np[1] + ho
			):
				continue
		else:
			areas_checked += 1
			if areas_overlap(building, new_room_area2d):
				new_room_area2d.queue_free()
				return
	#print(areas_checked)
	
	if areas_overlap(spawnarea, new_room_area2d):
			new_room_area2d.queue_free()
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
		
	buildings_local.append(new_room_area2d)

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
