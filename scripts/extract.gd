extends Area2D

signal extract_entered

func _on_body_entered(body):
	if body.name != G.PLAYER_NAME:
		return
	
	extract_entered.emit()
