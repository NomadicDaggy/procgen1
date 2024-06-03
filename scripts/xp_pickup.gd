extends Area2D

var xp_value: float
var flying_to_player: bool

func _ready():
	flying_to_player = false


func _physics_process(delta):
	# gets set externally
	if flying_to_player:
		var direction_towards_player = (G.player.global_position - global_position).normalized()
		global_position += 2 * direction_towards_player

func _on_body_entered(body):
	if body.name != G.PLAYER_NAME:
		return

	body.xp += xp_value
	
	queue_free()
