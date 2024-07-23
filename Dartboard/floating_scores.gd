extends Marker2D

@export var label : Label

func set_score(score: int):
	print("Setting score: ", score)  # Debug print
	if label:
		label.text = str(score)
		print("Label text set to: ", label.text)  # Debug print
	else:
		print("Error: Label node not found in Floating Score")

func _ready():
	if not label:
		print("Error: Label node not found in Floating Score")
		return

	print("Initial label text: ", label.text)  # Debug print
