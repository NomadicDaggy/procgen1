extends Area2D

var direction = Vector2.ZERO
var bullet_speed = 100

func _physics_process(delta):
	position += direction * delta * bullet_speed

func _on_body_entered(body):
	print("shot somebody")


func _on_timer_timeout():
	queue_free()
