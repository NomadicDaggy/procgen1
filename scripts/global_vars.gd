extends Node2D

# Tilesize in pixels
const TS: float = 16.0

# Chunksize in tiles
const CS: int = 64

const CS_PX = int(TS) * CS

const PLAYER_NAME = "Player"

var debug_mode = false

var rng = RandomNumberGenerator.new()


func round_to_dec(num, digit) -> float:
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func raycast_to_pos(from, to, collider_mask):
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(from, to, collider_mask)
	var result = space_state.intersect_ray(query)
	
	if result.size() == 0:
		return 0
	
	return result
