extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	
	# Got stuck in wall or smth
	if body.name != "Player":
		return
	
	print("You died!")
	Engine.time_scale = 0.1
	body.get_node("CollisionShape2D").queue_free()
	timer.start()


func _on_timer_timeout():
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
