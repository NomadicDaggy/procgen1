extends Area2D

var direction = Vector2.ZERO
var bullet_speed = 700

func _physics_process(delta):
	position += direction * delta * bullet_speed

func _on_body_entered(body):
	body.queue_free()
	queue_free()

func _on_timer_timeout():
	queue_free()
