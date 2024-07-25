extends Node

func _input(event: InputEvent) -> void:
	if event.is_action("ui_cancel"):
		get_tree().quit()
		
	if event.is_action("restart"):
		get_tree().reload_current_scene()
		
	if event.is_action("mousemodeoff"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
