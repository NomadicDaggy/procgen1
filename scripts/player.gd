extends CharacterBody2D

signal player_info_text_changed(text)

const BULLET = preload("res://scenes/bullet.tscn")

@onready var game_manager = $"../GameManager"
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var shot_timer = $ShotTimer
@onready var shot_light = $ShotLight
@onready var shot_light_timer = $ShotLight/ShotLightTimer
@onready var reload_timer = $ReloadTimer
@onready var player_main_light = $PointLight2D


@export var speed = 7000
@export var dead = false

const MAG_CAPACITY = 7
var shots_in_mag: int = MAG_CAPACITY
var round_in_chamber = true

func _ready():
	player_info_text_changed.emit(str(shots_in_mag))
	if G.debug_mode:
		player_main_light.shadow_enabled = false
		speed = 30000


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
	
	if dead:
		return
	
	if Input.get_action_strength("main_action"):
		try_shoot()
	if Input.get_action_strength("reload"):
		try_reload()


func try_shoot():
	if shots_in_mag <= 0:
		try_reload()
		return
		
	if not round_in_chamber or not reload_timer.is_stopped():
		return
	
	shot_timer.start()
	shots_in_mag -= 1
	shot_light.enabled = true
	shot_light_timer.start()

	var bullet = BULLET.instantiate()
	bullet.position = position
	bullet.direction = (get_global_mouse_position() - global_position).normalized()
	bullet.rotation = bullet.direction.angle() + PI/2
	bullet.z_index = 1500
	game_manager.add_child(bullet)
	
	# TODO: play shot sound
	round_in_chamber = false
	player_info_text_changed.emit(str(shots_in_mag))

func try_reload():
	if not reload_timer.is_stopped() or shots_in_mag == MAG_CAPACITY:
		return
	reload_timer.start()
	player_info_text_changed.emit("Reloading...")

func _on_shot_timer_timeout():
	round_in_chamber = true

func _on_shot_light_timer_timeout():
	shot_light.enabled = false

func _on_reload_timer_timeout():
	shots_in_mag = MAG_CAPACITY
	round_in_chamber = true
	reload_timer.stop()
	player_info_text_changed.emit(str(shots_in_mag))
