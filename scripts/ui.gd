extends CanvasLayer

@onready var world = $".."
@onready var debug = $Debug
@onready var navigation_region = $"../NavigationRegion2D"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	debug.text = str(world.get_global_mouse_position())
	

func _on_navigation_region_2d_bake_finished():
	print("bake finished")
	print(navigation_region.navigation_polygon)


func _on_navigation_region_2d_navigation_polygon_changed():
	print("nav poly changed")
