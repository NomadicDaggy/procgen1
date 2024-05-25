extends Area2D

signal self_destruct

@onready var spawn_timer = $SpawnTimer

@onready var timer = $Timer

func _on_body_entered(body):
	# Got stuck in wall or smth
	# Check only shortly after spawning
	if body.name != G.PLAYER_NAME:
		
		if spawn_timer.is_stopped():
			return
		
		# If in wall, destruct whole enemy
		self_destruct.emit()
		
		return
	
	print("You died!")
	body.dead = true
	Engine.time_scale = 0.1
	timer.start()
	body.get_node("CollisionShape2D").queue_free()


func _on_timer_timeout():
	print("timeout")
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
