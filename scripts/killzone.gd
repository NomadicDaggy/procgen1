extends Area2D

signal self_destruct

@onready var timer = $Timer

func _on_body_entered(body):
	
	# Got stuck in wall or smth
	if body.name != "Player":
		print("spawned in wall, destructing")
		get_parent().queue_free()
		return
	
	print("You died!")
	Engine.time_scale = 0.1
	body.get_node("CollisionShape2D").queue_free()
	timer.start()


func _on_timer_timeout():
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
