extends TileMap

signal map_ready

const EXTRACT = preload("res://scenes/extract.tscn")

@export var navigation_region: NavigationRegion2D

const WALL = Vector2i(2,0)
const BG = Vector2i(1,0)

const MAX_ROOMS_PER_CHUNK = 60
const MIN_ROOM_SIZE = 6
const MAX_ROOM_SIZE = 14
const MAX_ROOMS_TO_GEN_PER_FRAME = 3
#const MIN_ROOM_OFFSET = -60
#const MAX_ROOM_OFFSET = 60

@onready var buildings = $Buildings
@onready var spawnarea = $Spawnarea
@onready var player = $"../../Player"
@onready var extracts = $"../../GameManager/Extracts"


var generated_chunk_chunkcoords = []
var buildings_generated = 0
var buildings_local = []
var rooms_left_in_batch = 0
var chunk_queue = []
var chunk_in_generation

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for i in range(-2,2):
		for j in range(-2,2):
			generate_chunk_instant(Vector2i(i, j))
	call_deferred("nav_setup")
	
	print("buildings generated: ", buildings.get_child_count(), "  ", buildings_generated)


func _physics_process(_delta):
	
	#if Engine.get_physics_frames() % 30 != 0:
	
	# generate chunks if any ungenerated are near player
	var player_chunk_pos = Vector2i(
		int(player.global_position.x) / G.CS_PX,
		int(player.global_position.y) / G.CS_PX
	)
	
	# single chunk to generate
	_add_chunks_that_need_generation(player_chunk_pos)

	# Add a chunk to the room gen queue and prep background
	if (
		not chunk_in_generation
		and rooms_left_in_batch == 0
		and chunk_queue.size() > 0
		):
	
		chunk_in_generation = chunk_queue.pop_front()
		rooms_left_in_batch = MAX_ROOMS_PER_CHUNK

		build_bg(
			Vector2i(
				chunk_in_generation[0] * G.CS,
				chunk_in_generation[1] * G.CS),
			Vector2i(
				(chunk_in_generation[0] + 1) * G.CS,
				(chunk_in_generation[1] + 1) * G.CS))

		print("Starting chunkgen at ", chunk_in_generation)

	# If no chunk needs to be generated and none are currently in generation,
	# simply don't continue
	elif not chunk_in_generation:
		return
	
	
	var chunk_origin_in_tiles = chunk_in_generation * G.CS

	# Process rooms in batch
	for room_frame_i in MAX_ROOMS_TO_GEN_PER_FRAME:

		# If chunk just finished - reset for next chunk and break out
		if rooms_left_in_batch == 0:
			print("finished chunk")
			generated_chunk_chunkcoords.append(chunk_in_generation)
			chunk_in_generation = null
			# TODO: offset navigation baking or whatever causes the freeze (maybe it is generate_chunk_instant() instead)
			# TODO: currently calling multiple times even when one is already running
			call_deferred("nav_setup")
			break
		
		# Build room
		var width = G.rng.randi_range(MIN_ROOM_SIZE, MAX_ROOM_SIZE)
		var height = G.rng.randi_range(MIN_ROOM_SIZE, MAX_ROOM_SIZE)
		var offset = Vector2i(
			G.rng.randi_range(0, G.CS),
			G.rng.randi_range(0, G.CS))
		build_room(width, height, chunk_origin_in_tiles + offset)

		rooms_left_in_batch -= 1



func nav_setup():
	print("Baking navigation...")
	navigation_region.bake_navigation_polygon()
	map_ready.emit()


# chunk_coords are in chunk coordinates - i.e. how many chunks from origin
func generate_chunk_instant(chunk_coords: Vector2i):
	#print("generating chunk: ", chunk_coords)
	build_bg(
		Vector2i(chunk_coords[0] * G.CS, chunk_coords[1] * G.CS), 	
		Vector2i((chunk_coords[0] + 1) * G.CS, (chunk_coords[1] + 1) * G.CS))
	
	var chunk_origin_tiles = chunk_coords * G.CS
	# build buildings
	for i in range(MAX_ROOMS_PER_CHUNK):
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
	collision_shape.visible = false
	collision_shape.shape = RectangleShape2D.new()
	collision_shape.shape.size = Vector2((width + 1) * G.TS, (height + 1) * G.TS)
	var new_room_area2d = Area2D.new()
	new_room_area2d.visible = false
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

	# add extract
	if G.rng.randi_range(0, 80) == 1:
		
		var extract = EXTRACT.instantiate()
		extract.global_position = Vector2(
			offset[0] * G.TS + G.TS + wo,
			offset[1] * G.TS + G.TS + ho
		)
		print("adding extract at ", extract.global_position)
		extracts.add_child(extract)


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


func _add_chunks_that_need_generation(player_chunk_pos) -> void:
	for chunk_x in range(player_chunk_pos[0]-2, player_chunk_pos[0]+2):
		for chunk_y in range(player_chunk_pos[1]-2, player_chunk_pos[1]+2):
			var candidate_chunk = Vector2i(chunk_x, chunk_y)
			if (
					not generated_chunk_chunkcoords.has(candidate_chunk)
					and not chunk_queue.has(candidate_chunk)
					and chunk_in_generation != candidate_chunk
			):
				print("Adding chunk to queue: ", candidate_chunk)
				chunk_queue.append(candidate_chunk)


func _on_navigation_region_2d_bake_finished():
	print("bake finished")
	print(navigation_region.navigation_polygon)
