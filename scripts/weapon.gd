extends Node2D

const BULLET = preload("res://scenes/bullet.tscn")

var mag_capacity: int
var shots_in_mag: int
var round_in_chamber: bool
var bullet_speed: float

@onready var shot_timer = $ShotTimer
@onready var reload_timer = $ReloadTimer


# Called when the node enters the scene tree for the first time.
func _ready():
	mag_capacity = 20
	bullet_speed = 1000.0
	shots_in_mag = mag_capacity
	round_in_chamber = true

	reload_timer.wait_time = 1.5
	shot_timer.wait_time = 0.2

	
	UI.set_player_info_text(str(shots_in_mag))
	pass


func _process(_delta):
	pass

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
	bullet.bullet_speed = bullet_speed
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
