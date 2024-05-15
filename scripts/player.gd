extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D


const SPEED = 10000.0

func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * SPEED * delta
	
	if direction == Vector2(0,0):
		animated_sprite_2d.pause()
	else:
		animated_sprite_2d.play("walk")

	look_at(get_global_mouse_position())
	move_and_slide()
