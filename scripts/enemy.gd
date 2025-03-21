extends CharacterBody2D

enum State { PATROLLING, CHASING, IDLE, DEAD }

const BLOOD = preload("res://scenes/blood.tscn")
const XP_PICKUP = preload("res://scenes/xp_pickup.tscn")

@export var target: Node2D

@export var speed: int
@export var deceleration: int = 40
@export var acceleration: int
@export var state: State = State.PATROLLING
@export var health: float

@onready var navigation_agent: NavigationAgent2D = $Navigation/NavigationAgent2D
@onready var chase_timer: Timer = $ChaseTimer
@onready var patrol_path_timer: Timer = $PatrolPathTimer
@onready var debug_text: Label = $DebugText
@onready var debug_velocity_line: Line2D = $DebugVelocityLine
@onready var player_vision_area: Area2D = $PlayerVisionArea
@onready var got_hit_timer: Timer = $GotHitTimer

var patrol_margin: float
var patrol_speed: float
var patrol_accel: float
var chase_speed: float
var chase_accel: float
# @onready var unpredictability: float = G.rng.randf_range(0.5, 1.5)

var patrol_target: Vector2
var player_detection_level: float
var og_player_detection_level: float
var detection_radius: float
var trying_to_find_player_with_ray: bool

func _ready():
	trying_to_find_player_with_ray = false
	
	name = "ENEMY"
	z_index = 500
	health = 100.0
	debug_text.text = ""
	patrol_path_timer.wait_time = G.rng.randf_range(1, 2.5)
	chase_timer.wait_time = 4
	og_player_detection_level = G.rng.randf_range(0.1, 0.3)
	player_detection_level = og_player_detection_level

	detection_radius = 140.0  # pixels
	player_vision_area.get_child(0).shape.radius = detection_radius

	_randomize_behaviour()


func _physics_process(delta):
	
	var player_bodies_in_area = player_vision_area.get_overlapping_bodies()
	var detection_adjustment: float

	if player_bodies_in_area.size() > 0:
		var d = player_bodies_in_area[0].global_position.distance_to(global_position)
		var d_percent = 1 - (d / (detection_radius + 10))
		detection_adjustment = delta * d_percent * 1.2
	else:
		if state != State.CHASING:
			detection_adjustment = -delta

	player_detection_level = clampf(
		player_detection_level + detection_adjustment,
		og_player_detection_level,
		1.0
	)

	if health <= 0:
		state = State.DEAD
	
	match state:
		State.CHASING:
			var goal_pos = navigation_agent.get_next_path_position() - global_position
			move_to(goal_pos, chase_speed, chase_accel, delta)

		State.PATROLLING:
			# Reached desired patrol position, wait for a bit
			if global_position.distance_to(patrol_target) < G.TS:
				state = State.IDLE
				move_to((patrol_target - global_position), 0, -patrol_accel, delta)
			else:
				move_to((patrol_target - global_position), patrol_speed, patrol_accel, delta)

		State.IDLE:
			var decel_adjusted = deceleration
			if not got_hit_timer.is_stopped():
				decel_adjusted *= 2
			velocity = velocity.move_toward(Vector2.ZERO, decel_adjusted * delta)
			move_and_slide()

		State.DEAD:
			var new_xp_pickup = XP_PICKUP.instantiate()
			new_xp_pickup.z_index = 500
			new_xp_pickup.global_position = global_position
			new_xp_pickup.xp_value = 1
			get_parent().add_child(new_xp_pickup)

			target.enemies_killed += 1
			queue_free()
	
	if trying_to_find_player_with_ray:
		# collision mask is weird:
		# the results of 2 to the power of (layer to be enabled - 1).
		var raycast_result = G.raycast_to_pos(global_position, target.global_position, pow(2, 8-1))
		if not raycast_result:
			return
		
		if (raycast_result["collider"].name == G.PLAYER_NAME) and (player_detection_level == 1.0):
			state = State.CHASING
			chase_timer.start()
			
	debug_velocity_line.clear_points()
	debug_velocity_line.add_point( Vector2(0, 0) )
	debug_velocity_line.add_point( velocity )
	debug_velocity_line.global_rotation = 0


func _process(_delta):
	
	# If enemy is far from player, delete it to let a new one spawn closer.
	if global_position.distance_to(target.global_position) > 100 * G.TS:
		queue_free()

	modulate = Color(player_detection_level, 1, 1)
	
	debug_text.text = "%s\n" % G.round_to_dec(health, 1)
	#if G.debug_mode:
	#debug_text.text = "%s\n" % G.round_to_dec(player_detection_level,3)
	#debug_text.text = "%s\n" % G.round_to_dec(factor,1)
	debug_text.text  += "%s\n" % State.keys()[state]
	#debug_text.text += "%s" % G.round_to_dec(patrol_path_timer.time_left, 1)


func move_to(pos, s, a, d):
	var direction = pos.normalized()
	velocity = velocity.lerp(direction * s, a * d)
	move_and_slide()


func shot(projectile_stats):
	var blood_particles = BLOOD.instantiate()
	add_sibling(blood_particles)
	blood_particles.global_position = global_position
	blood_particles.look_at(target.global_position)
	health -= projectile_stats.damage
	
	# add impulse from bullet hit
	#projectile_stats.knockback_strength
	velocity = Vector2(projectile_stats.direction * projectile_stats.knockback_strength)

	if state != State.CHASING:
		got_hit_timer.start()
		#patrol_path_timer.stop()
		patrol_target = global_position
		state = State.PATROLLING


func _randomize_behaviour():
	patrol_margin = G.rng.randf_range(3 * G.TS, 15 * G.TS)
	patrol_speed = G.rng.randi_range(10, 50)
	patrol_accel = G.rng.randi_range(2, 4)
	chase_speed = clampf(patrol_speed * G.rng.randf_range(1.5, 5.0), 80, 150)
	chase_accel = clampf(patrol_accel * G.rng.randf_range(1.5, 5.0), 3, 6)


func _on_timer_timeout():
	if state == State.CHASING:
		navigation_agent.target_position = target.global_position
		
func _on_player_vision_area_body_entered(_body):
	trying_to_find_player_with_ray = true


func _on_chase_timer_timeout():
	state = State.PATROLLING
	player_detection_level = og_player_detection_level
	trying_to_find_player_with_ray = false
	print("gave up chasing")


func _on_patrol_path_timer_timeout():
	_randomize_behaviour()

	var px = position.x
	var py = position.y
	
	# set new patrol target
	patrol_target = Vector2(
		px + randf_range(-patrol_margin, patrol_margin),
		py + randf_range(-patrol_margin, patrol_margin))
		
	if state != State.CHASING:
		state = State.PATROLLING


func _on_killzone_self_destruct():
	queue_free()
