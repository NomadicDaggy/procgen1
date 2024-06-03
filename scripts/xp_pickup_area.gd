extends Area2D

func _on_area_entered(xp_pickup):
	xp_pickup.flying_to_player = true
