extends CenterContainer

@export var DOT_RADIUS : float = 1.0
@export var DOT_COLOR : Color = Color.AQUA

func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2(0,0),DOT_RADIUS,DOT_COLOR)
