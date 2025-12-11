extends Path2D

class_name PathFollow

@export var second_per_round: float = 100
@onready var follow: PathFollow2D = $PathFollow2D

func _process(delta: float) -> void:
	follow.progress_ratio += delta / second_per_round
