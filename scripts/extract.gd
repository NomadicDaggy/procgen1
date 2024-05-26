extends Area2D

signal extract

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
	extract.emit()
