extends Node2D

var enemy_scene = preload("res://scenes/enemy.tscn")
var rng = RandomNumberGenerator.new()

@onready var player = $"../Player"
@onready var enemies = $"./Enemies"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_map_map_ready():
	var r = 40
	while enemies.get_child_count() < 15:
		var x = rng.randi_range(-r,r)
		var y = rng.randi_range(-r,r)
		if (x > -10 and x < 10) or (y > -10 and y < 10):
			continue
		spawn_enemy(x, y)


func spawn_enemy(tile_pos_x: int, tile_pos_y: int):
	var enemy = enemy_scene.instantiate()
	enemy.position += Vector2(tile_pos_x * 16.0, tile_pos_y * 16.0)
	enemy.target = player
	enemy.z_index = 500
	enemies.add_child(enemy)


func _on_enemy_spawn_timer_timeout():
	var r = 100
	var x = rng.randi_range(-r,r)
	var y = rng.randi_range(-r,r)
	spawn_enemy(x, y)
