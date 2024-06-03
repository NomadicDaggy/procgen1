extends Node

# these should be set before _ready() gets called
@export var stat_type: G.StatType
@export var defaults: Dictionary
@export var info_header: String
@export var info_details: String
@export var progression: Array
@export var operation: G.Operation

@onready var value


func _ready():
	info_header = defaults.header
	info_details = defaults.details
	progression = defaults.progression
	operation = defaults.operation
