extends Node2D

@onready var player = $"../Player"
@onready var enemies = $"./Enemies"
@onready var enemy_spawn_timer = $EnemySpawnTimer
@onready var extracts = $Extracts


var enemy_nospawn_size = 40
var enemy_spawn_max_dist = 90
var max_enemies = 300


var enemy_scene = preload("res://scenes/enemy.tscn")

func _ready():
	Engine.time_scale = 1.0
	
	enemy_spawn_timer.wait_time = 0.03
	enemy_spawn_timer.autostart = true
	
	if G.debug_mode:
		enemy_nospawn_size = 8
		enemy_spawn_max_dist = 10
		max_enemies = 0


func spawn_enemy(pos: Vector2):
	var enemy = enemy_scene.instantiate()
	enemy.position += Vector2(pos[0], pos[1])
	enemy.target = player
	enemies.add_child(enemy)
	
	
func show_game_over():
	UI.game_over()
	Engine.time_scale = 0.0


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
