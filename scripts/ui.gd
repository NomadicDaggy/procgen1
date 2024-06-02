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
	debug.text += "\n"
	debug.text += "Movement speed: " + str(player.speed) + "\n"
	debug.text += "Reload speed: " + str(player.main_weapon.reload_timer.wait_time) + "\n"
	debug.text += "Projectile speed: " + str(player.main_weapon.bullet_speed) + "\n"


func set_player_info_text(text):
	if player_info:
		player_info.text = text
	

func player_died():
	results_controls.visible = true
	player_info.visible = false
	results_info.text = "Ripperino pepperonis!\n"


func present_level_up_choices(upgrade_names):
	level_up_container.visible = true

	# TODO: random upgrades, but no duplicates
	# TODO: proper choices if some already max level (currently functional, but visually buggy)
	for upgrade_name in upgrade_names:
		var upgrade_choice_item = LEVEL_UP_ITEM.instantiate()
		upgrade_choice_item.init_upgrade_name = upgrade_name
		var upgrade_details = G.UPGRADE_OPTIONS[upgrade_name]
		# TODO: Add roman numeral indicating stat level
		upgrade_choice_item.init_header_text = upgrade_details.header
		var next_stat_level = player.stat_levels[upgrade_name] + 1
		
		if upgrade_details.progression.size() <= next_stat_level:
			upgrade_choice_item.queue_free()
			continue
		
		var increase_by = upgrade_details.progression[next_stat_level]
		upgrade_choice_item.init_details_text = upgrade_details.details.replace("X", str(G.round_to_dec(increase_by, 2)))

		level_up_container.add_child(upgrade_choice_item)

	
func game_over():
	results_controls.visible = true
	player_info.visible = false
	results_info.text = "CONGRATS!\nYou bonked %s doodz." % player.enemies_killed


func clear_level_up_choices():
	level_up_container.visible = false

	for c in level_up_container.get_children():
		c.queue_free()


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
