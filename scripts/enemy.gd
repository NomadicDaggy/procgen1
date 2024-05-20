extends CharacterBody2D

@export var target: Node2D

@export var speed: int
@export var acceleration: int
@export var state = State.PATROLLING

@onready var navigation_agent: NavigationAgent2D = $Navigation/NavigationAgent2D
@onready var chase_timer = $ChaseTimer
@onready var patrol_path_timer = $PatrolPathTimer
@onready var debug_text = $DebugText
@onready var debug_velocity_line = $DebugVelocityLine

@onready var patrol_margin = G.rng.randf_range(0 * G.TS, 5 * G.TS)
@onready var chase_speed = G.rng.randi_range(35, 120)
@onready var chase_accel = G.rng.randi_range(5, 13)
@onready var patrol_speed = G.rng.randi_range(10, 50)
@onready var patrol_accel = G.rng.randi_range(2, 6)

#var chasing_target = false
enum State { PATROLLING, CHASING, IDLE, DEAD }

var patrol_target: Vector2
var detecting = false


func _ready():
	patrol_path_timer.wait_time = G.rng.randf_range(0.5, 4)

func _physics_process(delta):
	
	match state:
		State.CHASING:
			var goal_pos = navigation_agent.get_next_path_position() - global_position
			var distance_to_player = global_position.distance_to(target.global_position)

			if distance_to_player > 5 * G.TS:
				# TODO: debug this
				var factor = 1.2
				goal_pos += Vector2(goal_pos[0] + target.velocity[0] * factor, goal_pos[1] + target.velocity[1] * factor)
				
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
	
	if detecting:
		var space_state = get_world_2d().direct_space_state
		var col_mask = 2
		
		# TODO: add max length to player detecting raycast
		var query = PhysicsRayQueryParameters2D.create(global_position, target.global_position, col_mask)
		var result = space_state.intersect_ray(query)
		
		# no collision returns empty dict
		if result.size() == 0:
			return
			
		if result["collider"].name == G.PLAYER_NAME:
			state = State.CHASING
			chase_timer.start()
			
	debug_velocity_line.clear_points()
	debug_velocity_line.add_point( Vector2(0, 0) )
	debug_velocity_line.add_point( velocity )
	debug_velocity_line.global_rotation = 0


func _process(delta):
	debug_text.text = "%s\n" % State.keys()[state]
	debug_text.text += "%s" % G.round_to_dec(patrol_path_timer.time_left, 1)
	
	if global_position.distance_to(target.global_position) > 100 * G.TS:
		queue_free()


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

func _on_player_vision_area_body_entered(body):
	if body.name != G.PLAYER_NAME:
		return
	detecting = true

func _on_chase_timer_timeout():
	state = State.PATROLLING
	detecting = false
	print("gave up chasing")

func _on_patrol_path_timer_timeout():
	var px = position.x
	var py = position.y
	patrol_target = Vector2(px + randf_range(-patrol_margin, patrol_margin), py + randf_range(-patrol_margin, patrol_margin))
	if state != State.CHASING:
		state = State.PATROLLING
