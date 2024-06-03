extends Control

@export var stat_type: G.StatType

@onready var upgrade_header = $Panel/UpgradeName
@onready var upgrade_details = $Panel/UpgradeEffect

var init_header_text: String
var init_details_text: String
var init_stat_type: G.StatType


# Called when the node enters the scene tree for the first time.
func _ready():
	upgrade_header.text = init_header_text
	upgrade_details.text = init_details_text
	stat_type = init_stat_type


func _on_panel_gui_input(event):
	if event is InputEventMouseButton:
		print("Player chose upgrade")
		UI.clear_level_up_choices()
		SM.level_up_player(stat_type)
