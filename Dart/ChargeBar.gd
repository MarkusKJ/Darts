extends ProgressBar

@export var speed: float = 10.0  # Speed of the bar progression
var direction: int = 1  # 1 for increasing, -1 for decreasing

func _process(delta: float) -> void:
	value += speed * direction * delta
	
	if value >= max_value:
		direction = -1  # Start decreasing
	elif value <= min_value:
		direction = 1   # Start increasing
