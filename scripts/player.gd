extends CharacterBody2D

signal player_leveled_up

const WEAPON = preload("res://scenes/weapon.tscn")


@export var speed: Node
@export var accel: int
@export var xp: float
@export var level: int
@export var enemies_killed: int

@export var dead = false
@export var main_weapon: Node2D

@onready var game_manager = $"../GameManager"
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var player_main_light = $PointLight2D
@onready var player_projectiles = $"../GameManager/PlayerProjectiles"
@onready var on_spawn_timer = $OnSpawnTimer


func _ready():
	UI.player = self
	G.player = self

	speed = SM.init_upgradeable_stat(G.StatType.MOVEMENT_SPEED, 125)

	accel = 8
	xp = 0.0
	level = 1

	enemies_killed = 0
	
	var gun = WEAPON.instantiate()
	add_child(gun)
	main_weapon = gun
	
	if G.debug_mode:
		player_main_light.shadow_enabled = false
		speed.value = 500
		accel = 20


func _process(_delta):
	if xp >= SM.level_thresholds[level] and not G.game_paused:
		should_level_up()


func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	direction = direction.normalized()
	velocity = velocity.lerp(direction * speed.value, accel * delta)
	
	if direction == Vector2(0,0):
		animated_sprite_2d.pause()
	else:
		animated_sprite_2d.play("walk")

	look_at(get_global_mouse_position())
	move_and_slide()
	
	if dead:
		return
	
	if not on_spawn_timer.is_stopped():
		return

	if Input.get_action_strength("main_action"):
		main_weapon.try_shoot(player_projectiles, self)
	if Input.get_action_strength("reload"):
		main_weapon.try_reload()

	
func game_over():
	game_manager.pause_game()
	UI.player_died()


func should_level_up():
	print("Levelling up!")
	game_manager.pause_game()
	UI.present_level_up_choices()
