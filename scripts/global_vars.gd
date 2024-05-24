extends Node

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
	
func custom_ceil(num, ceil) -> float:
	return ceil if num > ceil else num
