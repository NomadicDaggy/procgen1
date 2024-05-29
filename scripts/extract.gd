extends Area2D

@onready var timer = $Timer


func _process(_delta):
	if not timer.is_stopped():
		UI.set_player_info_text(
			str(
				G.round_to_dec(timer.time_left, 2)
			)
		)


func _on_body_entered(body):
	if body.name != G.PLAYER_NAME:
		return
	
	timer.start()


func _on_body_exited(body):
	if body.name != G.PLAYER_NAME:
		return
		
	timer.stop()
	if not G.game_paused:
		UI.set_player_info_text(str(body.shots_in_mag))
	

func _on_timer_timeout():
	get_parent().get_parent().show_game_over()
