extends Control
@onready var host: Button = $Menu/Host
@onready var join: Button = $Menu/Join
@onready var start: Button = $Menu/Start


signal host_pressed
signal join_pressed
signal start_game

func _on_host_pressed() -> void:
	#Network.start_server()
	print("Waiting for players to join...")
	
func _on_join_pressed() -> void:
	#Network.start_client()
	print("Connecting to host...")
	start.visible = true

func _on_start_pressed() -> void:
	emit_signal('start_game')
