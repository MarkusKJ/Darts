extends Node3D
@onready var dartboard_cols: Node3D = $dartboard_cols
@onready var dbpl: ResourcePreloader = $dartboardPL

func _ready():
	dartboard_cols.connect("darthit", Callable(self, "_on_dart_hit"))

func _on_dart_hit(score: int, world_position: Vector3):
	spawn_floating_score(score, world_position)

func spawn_floating_score(score: int, world_position: Vector3):
	var score_instance = dbpl.get_resource("floating_scores").instantiate()
	score_instance.set_score(score)  # Assuming there's a method to set the score
	
	# Convert 3D world position to 2D screen position
	var screen_position = get_viewport().get_camera_3d().unproject_position(world_position)
	
	# Add the Marker2D to the scene and set its position
	add_child(score_instance)
	score_instance.position = screen_position

func get_last_hit_position() -> Vector3:
	return dartboard_cols.get_last_hit_position()
