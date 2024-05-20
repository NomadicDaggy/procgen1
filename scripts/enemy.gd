extends CharacterBody2D

@export var target: Node2D

@export var speed: int
@export var acceleration: int
@export var state = State.PATROLLING

@onready var navigation_agent: NavigationAgent2D = $Navigation/NavigationAgent2D
@onready var chase_timer = $ChaseTimer
@onready var patrol_path_timer = $PatrolPathTimer
@onready var debug_text = $DebugText

@onready var patrol_margin = G.rng.randf_range(0 * G.TS, 5 * G.TS)
@onready var chase_speed = G.rng.randi_range(35, 120)
@onready var chase_accel = G.rng.randi_range(5, 13)
@onready var patrol_speed = G.rng.randi_range(10, 50)
@onready var patrol_accel = G.rng.randi_range(2, 6)


#var chasing_target = false
enum State { PATROLLING, CHASING, IDLE, DEAD }

var patrol_target: Vector2


func _ready():
	patrol_path_timer.wait_time = G.rng.randf_range(0.5, 4)

func _physics_process(delta):
	match state:
		State.CHASING: 
			var direction = (navigation_agent.get_next_path_position() - global_position).normalized()
			velocity = velocity.lerp(direction * chase_speed, chase_accel * delta)
			move_and_slide()
		State.PATROLLING:
			if global_position.distance_to(patrol_target) < G.TS:
				state = State.IDLE
				var direction = (patrol_target - global_position).normalized()
				velocity = velocity.lerp(direction * 0, patrol_accel * delta)
			else:
				var direction = (patrol_target - global_position).normalized()
				velocity = velocity.lerp(direction * patrol_speed, patrol_accel * delta)
			move_and_slide()
		State.IDLE:
			move_and_slide()
		State.DEAD:
			pass


func _process(delta):
	debug_text.text = "%s\n" % State.keys()[state]
	debug_text.text += "%s" % G.round_to_dec(patrol_path_timer.time_left, 1)


func shot():
	state = State.DEAD
	queue_free()
	

func _on_timer_timeout():
	if state == State.CHASING:
		navigation_agent.target_position = target.global_position

func _on_player_vision_area_body_entered(body):
	if body.name == "Player":
		state = State.CHASING

func _on_player_vision_area_body_exited(body):
	if state == State.DEAD:
		return
	
	if body.name == "Player":
		chase_timer.start()

func _on_chase_timer_timeout():
	state = State.PATROLLING

func _on_patrol_path_timer_timeout():
	var px = position.x
	var py = position.y
	patrol_target = Vector2(px + randf_range(-patrol_margin, patrol_margin), py + randf_range(-patrol_margin, patrol_margin))
	if state != State.CHASING:
		state = State.PATROLLING
