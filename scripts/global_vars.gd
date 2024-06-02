extends Node2D


enum Operation { MULT_ADD, ADD }


# Tilesize in pixels
const TS: float = 16.0

# Chunksize in tiles
const CS: int = 64

# Chunksize in pixels
const CS_PX = int(TS) * CS

const PLAYER_NAME = "Player"

const UPGRADE_OPTIONS = {
	"movement_speed": {
		"header": "Movement Speed",
		"details": "+ X player movement speed",
		"progression": [0.07, 0.08, 0.09, 0.1, 0.11],
		"type": Operation.MULT_ADD,
	},
	"reload_speed": {
		"header": "Reload Speed",
		"details": "X sec on weapon reload time",
		"progression": [-0.2, -0.2, -0.2, -0.2, -0.2],
		"type": Operation.ADD,
	},
	"projectile_speed": {
		"header": "Projectile Speed",
		"details": "+ X units/sec weapon projectile speed",
		"progression": [200, 200, 200, 200, 200],
		"type": Operation.ADD,
	},
}

@export var player: CharacterBody2D

# ---------------------------
var debug_mode = false   # --
# ---------------------------

var godmode = false
var game_paused = true
var rng = RandomNumberGenerator.new()

var level_thresholds: Dictionary = {}

func _ready():
	if debug_mode:
		godmode = true

	# Setup level xp tresholds
	var lsum = 0
	for l in range(1, 20):
		level_thresholds[l] = round((1 + 0.75 * l) * (1.15 ** l)) + lsum
		lsum = level_thresholds[l]


func level_up_player(upgrade_name):
	player.level_up(upgrade_name)


func round_to_dec(num, digit) -> float:
	return round(num * pow(10.0, digit)) / pow(10.0, digit)


func raycast_to_pos(from, to, collider_mask):
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(from, to, collider_mask)
	var result = space_state.intersect_ray(query)
	
	if result.size() == 0:
		return 0
	
	return result
