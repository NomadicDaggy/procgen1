extends CharacterBody2D

const BULLET = preload("res://scenes/bullet.tscn")

@onready var game_manager = $"../GameManager"
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var shot_timer = $ShotTimer
@onready var shot_light = $ShotLight
@onready var shot_light_timer = $ShotLight/ShotLightTimer


@export var speed = 7000

var shot_available: bool = true

func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	direction = direction.normalized()
	velocity = direction * speed * delta
	
	if direction == Vector2(0,0):
		animated_sprite_2d.pause()
	else:
		animated_sprite_2d.play("walk")

	look_at(get_global_mouse_position())
	move_and_slide()
	
	if Input.get_action_strength("main_action"):
		if shot_available:
			shoot()
			shot_available = false
			shot_timer.start()


func shoot():
	shot_light.enabled = true
	shot_light_timer.start()
	var bullet = BULLET.instantiate()
	bullet.position = position
	bullet.direction = (get_global_mouse_position() - global_position).normalized()
	bullet.rotation = bullet.direction.angle() + PI/2
	bullet.z_index = 1500
	game_manager.add_child(bullet)


func _on_shot_timer_timeout():
	shot_available = true


func _on_shot_light_timer_timeout():
	shot_light.enabled = false
