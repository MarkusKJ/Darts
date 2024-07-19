extends Node3D

const ScoreMap = preload('res://Scripts/Globals/globals.gd').SCORE_MAP
var current_score = 0 

func _ready():
	# Connect signals for each Area3D node
	for area in get_tree().get_nodes_in_group("dartboard_sectors"):
		area.connect("body_entered", Callable(self, "_on_body_entered_sect").bind(area))
		
func _on_body_entered_sect(body: RigidBody3D, area: Area3D):
	if body.is_in_group("darts"): 
		var sector_name = area.name
		if ScoreMap.has(sector_name):
			var score = ScoreMap[sector_name]
			current_score += score
			body.freeze = true
			print("Hit sector: ", sector_name)
			print("Sector score: ", score)
			print("Total score: ", current_score)
		else:
			print("Warning: Unknown sector hit: ", sector_name)

func get_current_score() -> int:
	return current_score

func reset_score():
	current_score = 0
