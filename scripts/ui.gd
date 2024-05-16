extends CanvasLayer

@onready var world = $".."
@onready var debug = $Debug

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	debug.text = str(world.get_global_mouse_position())
