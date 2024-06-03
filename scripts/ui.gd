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
	debug.text += "Movement speed: " + str(player.speed.value) + "\n"
	debug.text += "Reload speed: " + str(player.main_weapon.reload_speed.value) + "\n"
	debug.text += "Projectile speed: " + str(player.main_weapon.projectile_speed.value) + "\n"


func set_player_info_text(text):
	if player_info:
		player_info.text = text
	

func player_died():
	results_controls.visible = true
	player_info.visible = false
	results_info.text = "Ripperino pepperonis!\n"


func present_level_up_choices():
	level_up_container.visible = true
	var stat_types = choose_n_random_stat_types(3)
	for stat_type in stat_types:
		var level_up_item = LEVEL_UP_ITEM.instantiate()
		level_up_item.init_stat_type = stat_type
		var stat = SM.get_stat_by_type(stat_type)
		var next_stat_level = SM.stat_levels[stat_type] + 1
		level_up_item.init_header_text = "%s %s" % [stat.info_header, G.int_to_roman(next_stat_level)]
		var increase_by = stat.progression[next_stat_level]
		level_up_item.init_details_text = stat.info_details.replace("X", str(G.round_to_dec(increase_by, 2)))
		level_up_item.init_details_text += "\n\n[color=gray]( %s -> %s )[/color]" % [stat.value, SM.get_stat_value_next_level(stat)]
		level_up_container.add_child(level_up_item)


func choose_n_random_stat_types(n):
	var stat_type_candidates: Array = range(G.StatType.size())
	var stat_types_chosen = []

	while stat_types_chosen.size() < n:
		if stat_type_candidates.size() == 0:
			# TODO: if stat_types_chosen.size() here, need to show to player
			return stat_types_chosen

		var type_index: int = G.rng.randi_range(0, stat_type_candidates.size() - 1)
		var type: int = stat_type_candidates[type_index]
		var next_stat_level = SM.stat_levels[type] + 1
		var stat = SM.get_stat_by_type(type)

		# max stat level reached
		if next_stat_level > stat.progression.size() - 1:
			stat_type_candidates.remove_at(type_index)
			continue
		
		stat_types_chosen.append(type)
		stat_type_candidates.remove_at(type_index)
	
	return stat_types_chosen

	
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
