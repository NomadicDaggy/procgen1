extends Node2D

var enemy_scene = preload("res://scenes/enemy.tscn")

@onready var player = $"../Player"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_map_map_ready():
	var rng = RandomNumberGenerator.new()
	var r = 40
	for i in 15:
		var x = rng.randi_range(-r,r)
		var y = rng.randi_range(-r,r)
		if (x > -10 and x < 10) or (y > -10 and y < 10):
			continue
		spawn_enemy(x, y)


func spawn_enemy(tile_pos_x: int, tile_pos_y: int):
	var enemy = enemy_scene.instantiate()
	enemy.position += Vector2(tile_pos_x * 16.0, tile_pos_y * 16.0)
	# TODO: check if enemy has been spawned within a wall
	enemy.target = player
	enemy.z_index = 500
	add_child(enemy)
