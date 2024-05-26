extends Area2D

@onready var timer = $Timer


func _on_body_entered(body):
	if body.name != G.PLAYER_NAME:
		return
	
	timer.start()


func _on_body_exited(body):
	if body.name != G.PLAYER_NAME:
		return
		
	timer.stop()
	

func _on_timer_timeout():
	get_parent().get_parent().show_game_over()
