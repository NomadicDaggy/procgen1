extends CanvasLayer

@onready var world = $".."
@onready var debug: Label = $Debug
@onready var navigation_region: NavigationRegion2D = $"../NavigationRegion2D"
@onready var player_info: Node = $PlayerInfo
@onready var enemies: Node2D = $"../GameManager/Enemies"
@onready var player: CharacterBody2D = $"../Player"


# Called when the node enters the scene tree for the first time.
func _ready():
	#player_info.set_position(player.position)
	#follow_viewport_enabled = true
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_hud()
	

func update_hud():
	var screen_center = get_viewport().get_visible_rect().size / 2
	var player_info_offset = Vector2(-50, -100)
	player_info.position = screen_center + player_info_offset

	debug.text =  "Mouse pos:   " + str(world.get_global_mouse_position()) + "\n"
	debug.text += "Enemy count: " + str(enemies.get_child_count())

func _on_navigation_region_2d_bake_finished():
	print("bake finished")
	print(navigation_region.navigation_polygon)


func _on_navigation_region_2d_navigation_polygon_changed():
	print("nav poly changed")


func _on_player_player_info_text_changed(text):
	player_info.text = text
