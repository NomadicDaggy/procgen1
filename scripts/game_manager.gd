extends Node2D

@onready var player = $"../Player"
@onready var enemies = $"./Enemies"
@onready var enemy_spawn_timer = $EnemySpawnTimer

const ENEMY_NOSPAWN_SIZE = 6
const ENEMY_SPAWN_MAX_DISTANCE = 25
const MAX_ENEMIES = 600

var enemy_scene = preload("res://scenes/enemy.tscn")

func _ready():
	enemy_spawn_timer.wait_time = 0.03
	enemy_spawn_timer.autostart = true

func _on_map_map_ready():
	# spawn enemies
	while enemies.get_child_count() < 15:
		var x = G.rng.randi_range(-ENEMY_SPAWN_MAX_DISTANCE, ENEMY_SPAWN_MAX_DISTANCE)
		var y = G.rng.randi_range(-ENEMY_SPAWN_MAX_DISTANCE, ENEMY_SPAWN_MAX_DISTANCE)
		if (
			(x > -ENEMY_NOSPAWN_SIZE and x < ENEMY_NOSPAWN_SIZE) or
			(y > -ENEMY_NOSPAWN_SIZE and y < ENEMY_NOSPAWN_SIZE)):
				continue
		spawn_enemy(Vector2(x,y))


func spawn_enemy(pos: Vector2):
	var enemy = enemy_scene.instantiate()
	enemy.position += Vector2(pos[0] * G.TS, pos[1] * G.TS)
	enemy.target = player
	enemy.z_index = 500
	enemies.add_child(enemy)


func _on_enemy_spawn_timer_timeout():
	if enemies.get_child_count() >= MAX_ENEMIES:
		return
	
	var r = 100 * G.TS
	var pos = Vector2(G.rng.randi_range(-r,r), G.rng.randi_range(-r,r))
	
	if pos.distance_to(player.global_position) < 40 * G.TS:
		return
		
	spawn_enemy(pos)
