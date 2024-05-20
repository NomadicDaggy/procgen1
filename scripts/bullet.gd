#TODO: If bullet speed is faster than 1000ish, the bullet area can pass
# through the target area. For faster bullets we would need to raycast
# (maybe not every frame since enemies are slow) back in the direction
# of the player to see if we might have gone through an enemy.

extends Area2D

var direction = Vector2.ZERO
var bullet_speed = 750

func _ready():
	z_index = 1500

func _physics_process(delta):
	position += direction * delta * bullet_speed

func _on_body_entered(body):
	body.shot()
	queue_free()

func _on_timer_timeout():
	queue_free()
