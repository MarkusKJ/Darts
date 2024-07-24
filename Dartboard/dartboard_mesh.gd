extends Node3D

var player_materials = []
var sector_materials = {}

func _ready():
	# Create materials for each player
	player_materials = [
		create_player_material(Color.RED),
		create_player_material(Color.BLUE),
		# Add more colors for additional players
	]

	# Assign initial materials to sectors
	for sector in get_children():
		if sector is MeshInstance3D and sector.name != "Frame":
			var initial_material = create_player_material(Color.WHITE)
			sector.set_surface_override_material(0, initial_material)
			sector_materials[sector.name] = initial_material

	# Connect to the collision detection signal
	var collision_node = get_parent_node_3d()  # Adjust path as needed
	collision_node.connect("sector_hit", Callable(self, "_on_sector_hit"))

func create_player_material(color: Color) -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	return material

func _on_sector_hit(sector_name: String, player_index: int):
	if sector_materials.has(sector_name) and player_index < player_materials.size():
		var sector = get_node(sector_name)
		if sector is MeshInstance3D:
			sector.set_surface_override_material(0, player_materials[player_index])

func reset_colors():
	for sector in get_children():
		if sector is MeshInstance3D:
			sector.set_surface_override_material(0, create_player_material(Color.WHITE))
