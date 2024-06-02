#TODO: If bullet speed is faster than 1000ish, the bullet area can pass
# through the target area. For faster bullets we would need to raycast
# (maybe not every frame since enemies are slow) back in the direction
# of the player to see if we might have gone through an enemy.

extends Area2D

var direction = Vector2.ZERO
var bullet_speed: float
@export var shooter: CharacterBody2D

func _ready():
	z_index = 600

func _physics_process(delta):
	position += direction * delta * bullet_speed
	
	# TODO: raycast is immediate, but bullet has flight time.
	# Either way sometimes this causes enemy to be hit even bullet does not
	# cross its path
	var ray_result = G.raycast_to_pos(global_position, shooter.global_position, 7)
	if ray_result and ray_result["collider"].is_in_group("shootable"):
		_on_body_entered(ray_result["collider"])
	

func _on_body_entered(body):
	if body.is_in_group("shootable"):
		body.shot()
	
	queue_free()

func _on_timer_timeout():
	queue_free()
