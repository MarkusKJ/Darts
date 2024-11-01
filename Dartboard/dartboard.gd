extends Node3D

signal darthit(score: int, position: Vector3)
signal sector_hit(sector_name: String, player_index: int)

const ScoreMap = preload('res://Scripts/Globals/GameGlobals.gd').SCORE_MAP

@onready var dartboard_cols: Node3D = $dartboard_cols
@onready var dbpl: ResourcePreloader = $dartboardPL

var current_score = 0 
var last_hit_position = Vector3.ZERO
var last_hit_score = 0
var processed_darts = []

func _ready():
	# Connect signals for each Area3D node
	for area in get_tree().get_nodes_in_group("dartboard_sectors"):
		area.connect("body_entered", Callable(self, "_on_body_entered_sect").bind(area))
	
func _on_body_entered_sect(body: RigidBody3D, area: Area3D):
	if body.is_in_group("darts"):
		processed_darts.append(body)
		body.freeze = true 
		var sector_name = area.name
		if ScoreMap.has(sector_name):
			var score = ScoreMap[sector_name]
			current_score += score
			last_hit_score = score
			last_hit_position = body.global_transform.origin
			meshsignal(body, area)
			emit_signal("darthit", score, last_hit_position)
			_on_dart_hit(score, last_hit_position)
			print("Hit sector: ", sector_name)
			print("Sector score: ", score)
			print("Total score: ", current_score)

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

func get_current_score() -> int:
	return current_score

func get_last_hit_position() -> Vector3:
	return last_hit_position

func get_last_hit_score() -> int:
	return last_hit_score

func reset_score():
	current_score = 0
	last_hit_position = Vector3.ZERO
	last_hit_score = 0
	processed_darts.clear()

func meshsignal(body:RigidBody3D, area: Area3D):
	var player_index = body.get_meta("player_index") if body.has_meta("player_index") else 0
	emit_signal("sector_hit", area.name, player_index)

func clear_processed_darts():
	processed_darts.clear()
