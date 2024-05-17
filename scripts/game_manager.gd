extends Node2D

var enemy_scene = preload("res://scenes/enemy.tscn")

@onready var player = $"../Player"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_map_map_ready():
	spawn_enemies()


func spawn_enemies():
	var enemy = enemy_scene.instantiate()
	enemy.position += Vector2(3.0 * 16.0, 5.0 * 16.0)
	enemy.target = player
	enemy.z_index = 500
	add_child(enemy)
