extends Label


func _ready() -> void:
	name = str(get_multiplayer_authority())
	text = str(name)
	print("player instanciated:%",name)
