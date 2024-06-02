extends Area2D

var xp_value: float

func _ready():
	pass


func _on_body_entered(body):
	if body.name != G.PLAYER_NAME:
		return

	body.xp += xp_value
	
	queue_free()
