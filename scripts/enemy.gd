extends CharacterBody2D

@export var target: Node2D

@export var speed: int
@export var acceleration: int
@export var state = PATROLLING

@onready var navigation_agent: NavigationAgent2D = $Navigation/NavigationAgent2D
@onready var chase_timer = $ChaseTimer
@onready var patrol_path_timer = $PatrolPathTimer

@onready var rng = RandomNumberGenerator.new()
@onready var patrol_margin = rng.randf_range(0 * 16.0, 5 * 16.0)
@onready var chase_speed = rng.randi_range(35, 120)
@onready var chase_accel = rng.randi_range(5, 13)
@onready var patrol_speed = rng.randi_range(10, 50)
@onready var patrol_accel = rng.randi_range(2, 6)


#var chasing_target = false
enum { PATROLLING, CHASING, IDLE, DEAD }

var patrol_target: Vector2


func _ready():
	patrol_path_timer.wait_time = rng.randf_range(0.5, 4)

func _physics_process(delta):
	match state:
		CHASING: 
			var direction = (navigation_agent.get_next_path_position() - global_position).normalized()
			velocity = velocity.lerp(direction * chase_speed, chase_accel * delta)
			move_and_slide()
		PATROLLING:
			if global_position.distance_to(patrol_target) < 16.0:
				state = IDLE
			else:
				var direction = (patrol_target - global_position).normalized()
				velocity = velocity.lerp(direction * patrol_speed, patrol_accel * delta)
			move_and_slide()
		IDLE:
			move_and_slide()
		DEAD:
			pass
			


func shot():
	state = DEAD
	queue_free()
	

func _on_timer_timeout():
	if state == CHASING:
		navigation_agent.target_position = target.global_position

func _on_player_vision_area_body_entered(body):
	if body.name == "Player":
		state = CHASING

func _on_player_vision_area_body_exited(body):
	if state == DEAD:
		return
	
	if body.name == "Player":
		chase_timer.start()

func _on_chase_timer_timeout():
	state = PATROLLING

func _on_patrol_path_timer_timeout():
	var px = position.x
	var py = position.y
	patrol_target = Vector2(px + randf_range(-patrol_margin, patrol_margin), py + randf_range(-patrol_margin, patrol_margin))
	if state != CHASING:
		state = PATROLLING
