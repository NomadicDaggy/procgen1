extends CanvasLayer

const LEVEL_UP_ITEM = preload("res://scenes/level_up_item.tscn")

@onready var world: Node2D #= $"../world"
@onready var navigation_region: NavigationRegion2D #= $"../world/NavigationRegion2D"
@onready var enemies: Node2D #= $"../world/GameManager/Enemies"
@onready var game_manager: Node2D

@onready var debug: Label = $Debug
@onready var player_info = $PlayerInfo
@onready var results_controls = $ResultsControls
@onready var results_info = $ResultsControls/ResultsInfo
@onready var start_controls = $StartControls
@onready var level_up_container = $LevelUpContainer


@export var player: CharacterBody2D


func _ready():
	start_controls.visible = true
	player_info.visible = false
	results_controls.visible = false
	level_up_container.visible = false


func _process(_delta):
	
	# scene has been reloaded, so set necessary links
	if not world:
		world = get_node("../world")
		navigation_region = get_node("../world/NavigationRegion2D")
		enemies = get_node("../world/GameManager/Enemies")
		game_manager = get_node("../world/GameManager")
	
	update_hud()
	

func update_hud():
	
	# After scene reload, sometimes viewport isn't instantly available
	if not get_viewport():
		return

	var screen_center = get_viewport().get_visible_rect().size / 2
	var player_info_offset = Vector2(-50, -100)
	player_info.position = screen_center + player_info_offset

	debug.text = ""
	#debug.text =  "Mouse pos:   " + str(world.get_global_mouse_position()) + "\n"
	#debug.text += "Enemy count: " + str(enemies.get_child_count())
	debug.text += "XP: " + str(player.xp) + "\n"
	debug.text += "LVL: " + str(player.level) + "\n"


func set_player_info_text(text):
	if player_info:
		player_info.text = text
	

func player_died():
	results_controls.visible = true
	player_info.visible = false
	results_info.text = "Ripperino pepperonis!\n"

func player_leveled_up():
	level_up_container.visible = true
	
	for _i in 3:
		var upgrade_choice_panel = LEVEL_UP_ITEM.instantiate()
		level_up_container.add_child(upgrade_choice_panel)

	
func game_over():
	results_controls.visible = true
	player_info.visible = false
	results_info.text = "CONGRATS!\nYou bonked %s doodz." % player.enemies_killed


func _on_restart_button_pressed():
	if not results_controls.visible:
		return
	
	get_parent().get_tree().reload_current_scene()
	
	results_controls.visible = false
	player_info.visible = true
	G.game_paused = false


func _on_start_game_button_pressed():
	results_controls.visible = false
	player_info.visible = true
	start_controls.visible = false
	
	game_manager.unpause_game()
