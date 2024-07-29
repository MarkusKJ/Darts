extends Node3D

@onready var dartspawner = $DartSpawner
@onready var dartboard = $dartboard
@onready var main_menu: Control = $UICanvas/MainMenu


#var current_score: int = 0
#var game_started: bool = false

func _ready():
	pass
	"""hide_game_elements()
	show_main_menu()
	
	# Connect dartboard signals
	dartboard.connect("darthit", Callable(self, "_on_dart_hit"))
	main_menu.connect("start_game", Callable(self, "start_game"))

func hide_game_elements():
	dartspawner.visible = false
	dartboard.visible = false

func show_main_menu():
	main_menu.visible = true

func start_game():
	game_started = true
	hide_main_menu()
	show_game_elements()
	initialize_game_state()

func hide_main_menu():
	main_menu.visible = false

func show_game_elements():
	dartspawner.visible = true
	dartboard.visible = true

func _on_player_connected(id: int):
	printraw("Player Connected:%",id)

func initialize_game_state():
	# Set up initial game state
	printerr("DEBUG: Initializing game state")
	pass
"""
