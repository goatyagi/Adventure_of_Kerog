extends level_base

@onready var animation: AnimationPlayer = $Door1/Animation1
@onready var animation2: AnimationPlayer = $Door2/Animation2

var is_called_1 = false
var is_called_2 = false

func _physics_process(_delta):
    if animation.is_playing():
        if player == null or player_2 == null:
            animation.stop()
            is_called_1 = false

    if animation2.is_playing():
        if player == null or player_2 == null:
            animation2.stop()
            is_called_2 = false

func _on_area_2d_body_entered(_body: Node2D):
    if !is_called_1:
        is_called_1 = true
        animation.play("10sec_1")


func _on_door_2_body_entered(_body: Node2D):
    if !is_called_2:
        is_called_2 = true
        animation2.play("10sec")
