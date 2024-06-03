extends Node

const UPGRADEABLE_STAT = preload("res://scenes/upgradeable_stat.tscn")

const UPGRADE_DEFAULTS = {
	G.StatType.MOVEMENT_SPEED: {
		"header": "Movement Speed",
		"details": "+ X player movement speed",
		"progression": [null, 0.07, 0.08, 0.09, 0.1, 0.11],
		"operation": G.Operation.MULT_ADD,
	},
	G.StatType.RELOAD_SPEED: {
		"header": "Reload Speed",
		"details": "X sec on weapon reload time",
		"progression": [null, -0.2, -0.2, -0.2, -0.2, -0.2],
		"operation": G.Operation.ADD,
	},
	G.StatType.PROJECTILE_SPEED: {
		"header": "Projectile Speed",
		"details": "+ X units/sec weapon projectile speed",
		"progression": [null, 200, 200, 200, 200, 200],
		"operation": G.Operation.ADD,
	},
}

@export var stat_levels: Dictionary = {}

var level_thresholds: Dictionary = {}


func _ready():
	# Setup level xp tresholds
	#var lsum = 0
	for l in range(1, 20):
		#level_thresholds[l] = round((1 + 0.75 * l) * (1.15 ** l)) + lsum
		level_thresholds[l] = l * 1
		#lsum = level_thresholds[l]
	
	for stat in SM.UPGRADE_DEFAULTS.keys():
		stat_levels[stat] = 0


func init_upgradeable_stat(type, value) -> Node:
	var n = UPGRADEABLE_STAT.instantiate()
	n.stat_type = type
	n.defaults = SM.UPGRADE_DEFAULTS[type]
	n.value = value
	SM.add_child(n)
	return n



func level_up_player(stat_type: G.StatType):
	G.player.level += 1
	increment_stat_level(stat_type)
	G.game_manager.unpause_game()


func increment_stat_level(stat_type: G.StatType):
	var stat = get_stat_by_type(stat_type)
	stat.value = get_stat_value_next_level(stat)
	stat_levels[stat_type] += 1


func get_stat_value_next_level(stat: Node):
	var next_stat_level = stat_levels[stat.stat_type] + 1
	return perform_operation(stat, stat.progression[next_stat_level])


func get_stat_by_type(stat_type: G.StatType) -> Node:
	for node in get_children():
		if node.stat_type == stat_type:
			return node
	return null


func perform_operation(on: Node, by):
	match on.operation:
		G.Operation.ADD:
			return on.value + by
		G.Operation.MULT_ADD:
			return on.value + on.value * by
