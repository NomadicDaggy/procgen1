extends Area2D

signal self_destruct
signal player_died

@onready var spawn_timer = $SpawnTimer
@onready var stuck_check_timer = $StuckCheckTimer


@onready var timer = $Timer

var player: CharacterBody2D

func _ready():
	pass

func _on_body_entered(body):

	if G.godmode:
		return

	# Got stuck in wall or smth
	# Check only shortly after spawning
	if body.name != G.PLAYER_NAME:
		
		if spawn_timer.is_stopped():
			return
		
		# If in wall, destruct whole enemy
		self_destruct.emit()
		
		return
	
	print("You died!")
	body.dead = true
	Engine.time_scale = 0.1
	
	player = body
	timer.start()
	
	#body.get_node("CollisionShape2D").queue_free()


func _on_timer_timeout():
	player.game_over()


func _on_stuck_check_timer_timeout():
	if get_overlapping_areas().size() > 0:
		print("Am stuck, despawning")
		self_destruct.emit()
