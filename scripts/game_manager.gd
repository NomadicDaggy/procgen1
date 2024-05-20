extends Node2D

@onready var player = $"../Player"
@onready var enemies = $"./Enemies"

const ENEMY_NOSPAWN_SIZE = 6
const ENEMY_SPAWN_MAX_DISTANCE = 25

var enemy_scene = preload("res://scenes/enemy.tscn")
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _on_map_map_ready():
	# spawn enemies
	while enemies.get_child_count() < 15:
		var x = rng.randi_range(-ENEMY_SPAWN_MAX_DISTANCE, ENEMY_SPAWN_MAX_DISTANCE)
		var y = rng.randi_range(-ENEMY_SPAWN_MAX_DISTANCE, ENEMY_SPAWN_MAX_DISTANCE)
		if (
			(x > -ENEMY_NOSPAWN_SIZE and x < ENEMY_NOSPAWN_SIZE) or
			(y > -ENEMY_NOSPAWN_SIZE and y < ENEMY_NOSPAWN_SIZE)):
				continue
		spawn_enemy(x, y)


func spawn_enemy(tile_pos_x: int, tile_pos_y: int):
	var enemy = enemy_scene.instantiate()
	enemy.position += Vector2(tile_pos_x * 16.0, tile_pos_y * 16.0)
	enemy.target = player
	enemy.z_index = 500
	enemies.add_child(enemy)


func _on_enemy_spawn_timer_timeout():
	if enemies.get_child_count() >= 120:
		return
	
	var r = 100
	var x = rng.randi_range(-r,r)
	var y = rng.randi_range(-r,r)
	spawn_enemy(x, y)
