extends CanvasLayer

@onready var world: Node2D #= $"../world"
@onready var navigation_region: NavigationRegion2D #= $"../world/NavigationRegion2D"
@onready var enemies: Node2D #= $"../world/GameManager/Enemies"

@onready var debug: Label = $Debug
@onready var player_info = $PlayerInfo
@onready var results_controls = $ResultsControls
@onready var results_info = $ResultsControls/ResultsInfo


@export var player: CharacterBody2D


func _ready():
	#call_deferred("set_player_info_text", str(player.ranged_weapon.shots_in_mag))
	pass


func _process(_delta):
	
	# scene has been reloaded, so set necessary links
	if not world:
		world = get_node("../world")
		navigation_region = get_node("../world/NavigationRegion2D")
		enemies = get_node("../world/GameManager/Enemies")
	
	update_hud()
	

func update_hud():
	
	# After scene reload, sometimes viewport isn't instantly available
	if not get_viewport():
		return

	var screen_center = get_viewport().get_visible_rect().size / 2
	var player_info_offset = Vector2(-50, -100)
	player_info.position = screen_center + player_info_offset

	debug.text =  "Mouse pos:   " + str(world.get_global_mouse_position()) + "\n"
	debug.text += "Enemy count: " + str(enemies.get_child_count())


func set_player_info_text(text):
	if player_info:
		player_info.text = text
	

func player_died():
	results_controls.visible = true
	player_info.visible = false
	results_info.text = "YOU DIED!\n"
	
	
func game_over():
	results_controls.visible = true
	player_info.visible = false
	results_info.text = "CONGRATS!\n"


# Access object and reassign it to the correct node if needed
#func _aor(object, node_name):


func _on_restart_button_pressed():
	get_parent().get_tree().reload_current_scene()
	results_controls.visible = false
	player_info.visible = true
