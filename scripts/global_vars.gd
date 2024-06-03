extends Node2D

enum Operation { MULT_ADD, ADD }

enum StatType { MOVEMENT_SPEED, RELOAD_SPEED, PROJECTILE_SPEED }

# Tilesize in pixels
const TS: float = 16.0

# Chunksize in tiles
const CS: int = 64

# Chunksize in pixels
const CS_PX = int(TS) * CS

const PLAYER_NAME = "Player"

@export var player: CharacterBody2D
@export var game_manager: Node2D


# ---------------------------
var debug_mode = false   # --
# ---------------------------

var godmode = false
var game_paused = true
var rng = RandomNumberGenerator.new()

func _ready():
	if debug_mode:
		godmode = true


func round_to_dec(num, digit) -> float:
	return round(num * pow(10.0, digit)) / pow(10.0, digit)


func raycast_to_pos(from, to, collider_mask):
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(from, to, collider_mask)
	var result = space_state.intersect_ray(query)
	
	if result.size() == 0:
		return 0
	
	return result

func int_to_roman(i) -> String:
	return { 1: "I", 2: "II", 3: "III", 4: "IV", 5: "V", }[i]
