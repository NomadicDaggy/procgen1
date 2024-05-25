extends Node2D

@onready var player = $"../Player"
@onready var enemies = $"./Enemies"
@onready var enemy_spawn_timer = $EnemySpawnTimer

var enemy_nospawn_size = 40
var enemy_spawn_max_dist = 90
var max_enemies = 300


var enemy_scene = preload("res://scenes/enemy.tscn")

func _ready():
	enemy_spawn_timer.wait_time = 0.03
	enemy_spawn_timer.autostart = true
	
	if G.debug_mode:
		enemy_nospawn_size = 8
		enemy_spawn_max_dist = 10
		max_enemies = 0


func spawn_enemy(pos: Vector2):
	var enemy = enemy_scene.instantiate()
	enemy.name = "ENEMY"
	enemy.position += Vector2(pos[0], pos[1])
	enemy.target = player
	enemy.z_index = 500
	enemy.modulate = Color(G.rng.randf_range(0.15, 0.45), 1, 1)
	enemies.add_child(enemy)


func _on_enemy_spawn_timer_timeout():
	if enemies.get_child_count() >= max_enemies:
		return
	
	var r = enemy_spawn_max_dist * G.TS
	var p = player.global_position
	var pos = Vector2(
		G.rng.randi_range( p[0] - r, p[0] + r ),
		G.rng.randi_range( p[1] - r, p[1] + r )
	)
	
	if pos.distance_to(p) < enemy_nospawn_size * G.TS:
		return
		
	spawn_enemy(pos)
