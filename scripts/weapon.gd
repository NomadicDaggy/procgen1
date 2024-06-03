extends Node2D

const BULLET = preload("res://scenes/bullet.tscn")

@export var mag_capacity: int
@export var shots_in_mag: int
@export var round_in_chamber: bool
@export var projectile_speed: Node
@export var reload_speed: Node

@onready var shot_timer = $ShotTimer
@onready var reload_timer = $ReloadTimer


# Called when the node enters the scene tree for the first time.
func _ready():
	mag_capacity = 20
	shots_in_mag = mag_capacity
	round_in_chamber = true
	projectile_speed = SM.init_upgradeable_stat(G.StatType.PROJECTILE_SPEED, 1000.0)
	reload_speed = SM.init_upgradeable_stat(G.StatType.RELOAD_SPEED, 1.5)

	reload_timer.wait_time = reload_speed.value
	shot_timer.wait_time = 0.2

	
	UI.set_player_info_text(str(shots_in_mag))
	pass


func _process(_delta):
	if reload_timer.wait_time != reload_speed.value:
		reload_timer.wait_time = reload_speed.value

func _physics_process(_delta):
	pass


func try_shoot(bullet_container, player):
	if shots_in_mag <= 0:
		try_reload()
		return
		
	if not round_in_chamber or not reload_timer.is_stopped():
		return
	
	shot_timer.start()
	shots_in_mag -= 1

	var bullet = BULLET.instantiate()
	bullet.shooter = player
	bullet.global_position = global_position
	bullet.direction = (get_global_mouse_position() - global_position).normalized()
	bullet.bullet_speed = projectile_speed.value
	bullet.rotation = bullet.direction.angle() + PI/2
	bullet.z_index = 1500
	bullet_container.add_child(bullet)
	
	round_in_chamber = false
	UI.set_player_info_text(str(shots_in_mag))

func try_melee_attack():
	pass

func try_reload():
	if not reload_timer.is_stopped() or shots_in_mag == mag_capacity:
		return
	reload_timer.start()
	UI.set_player_info_text("Reloading...")


func _on_shot_timer_timeout():
	round_in_chamber = true

func _on_reload_timer_timeout():
	shots_in_mag = mag_capacity
	round_in_chamber = true
	reload_timer.stop()
	UI.set_player_info_text(str(shots_in_mag))
