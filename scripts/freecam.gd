extends Camera2D

@export var in_freecam = false
@onready var player_camera = $"../Player/Camera2D"
@onready var player_info = $"../UI/PlayerInfo"
@onready var player_light = $"../Player/PointLight2D"


const zoom_increment = 0.15

var fixed_toggle_point = Vector2(0,0)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if Input.is_action_just_released("toggle_camera"):
		# Go back to player camera
		if in_freecam:
			in_freecam = false
			player_info.visible = true
			player_camera.make_current()
			player_light.shadow_enabled = true
			Engine.time_scale = 1.0
			
		# Go into freecam
		else:
			in_freecam = true
			player_info.visible = false
			make_current()
			player_light.shadow_enabled = false
			Engine.time_scale = 0.0
	
	if in_freecam:
		if Input.is_action_just_released("scroll_up"):
			zoom = clamp(
				zoom +
				Vector2(zoom_increment, zoom_increment),
				Vector2(zoom_increment, zoom_increment),
				Vector2(10.35, 10.35)
			)
		if Input.is_action_just_released("scroll_down"):
			zoom = clamp(
				zoom -
				Vector2(zoom_increment, zoom_increment),
				Vector2(zoom_increment, zoom_increment),
				Vector2(10.35, 10.35)
			)
			
		if Input.is_action_just_pressed("middle_mouse_btn"):
			var ref = get_viewport().get_mouse_position()
			fixed_toggle_point = ref
		if Input.is_action_pressed("middle_mouse_btn"):
			move_map_around()

# moves the map around just like in the editor
func move_map_around():
	var ref = get_viewport().get_mouse_position()
	global_position.x -= (ref.x - fixed_toggle_point.x)
	global_position.y -= (ref.y - fixed_toggle_point.y)
	fixed_toggle_point = ref
