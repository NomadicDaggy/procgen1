extends CharacterBody2D

enum State { PATROLLING, CHASING, IDLE, DEAD }

@export var target: Node2D

@export var speed: int
@export var acceleration: int
@export var state: State = State.PATROLLING

@onready var navigation_agent: NavigationAgent2D = $Navigation/NavigationAgent2D
@onready var chase_timer: Timer = $ChaseTimer
@onready var patrol_path_timer: Timer = $PatrolPathTimer
@onready var debug_text: Label = $DebugText
@onready var debug_velocity_line: Line2D = $DebugVelocityLine
@onready var player_vision_area = $PlayerVisionArea


@onready var patrol_margin: float = G.rng.randf_range(0 * G.TS, 5 * G.TS)
@onready var patrol_speed: float = G.rng.randi_range(10, 50)
@onready var patrol_accel: float = G.rng.randi_range(2, 4)
@onready var chase_speed: float = clampf(patrol_speed * G.rng.randf_range(1.5, 5.0), 80, 150)
@onready var chase_accel: float = clampf(patrol_accel * G.rng.randf_range(1.5, 5.0), 3, 6)

var patrol_target: Vector2
var player_detection_level: float
var og_player_detection_level: float
var detection_radius: float
var trying_to_find_player_with_ray: bool

func _ready():
	trying_to_find_player_with_ray = false
	
	name = "ENEMY"
	z_index = 500
	debug_text.text = ""
	patrol_path_timer.wait_time = G.rng.randf_range(1, 2.5)
	chase_timer.wait_time = 4
	og_player_detection_level = G.rng.randf_range(0.1, 0.3)
	player_detection_level = og_player_detection_level

	detection_radius = 140.0  # pixels
	player_vision_area.get_child(0).shape.radius = detection_radius


func _physics_process(delta):
	
	var overlapping_bodies = player_vision_area.get_overlapping_bodies()
	var detection_adjustment: float

	if overlapping_bodies.size() > 0:
		var d = overlapping_bodies[0].global_position.distance_to(global_position)
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
			move_and_slide()

		State.DEAD:
			pass
	
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
	
	#if G.debug_mode:
	#debug_text.text = "%s\n" % G.round_to_dec(player_detection_level,3)
	#debug_text.text = "%s\n" % G.round_to_dec(factor,1)
	#debug_text.text = "%s\n" % State.keys()[state]
	#debug_text.text += "%s" % G.round_to_dec(patrol_path_timer.time_left, 1)


func move_to(pos, s, a, d):
	var direction = pos.normalized()
	velocity = velocity.lerp(direction * s, a * d)
	move_and_slide()


func shot():
	state = State.DEAD
	queue_free()


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
