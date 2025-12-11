extends Area2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

var respawn_point = Vector2(0, 0)
var checked = false

func _on_body_entered(body: Node2D):
	if !checked:
		animation.play("checked")
		respawn_point = body.position
		SignalManager.on_checkpoint.emit(respawn_point)
		checked = true

func _on_animated_sprite_2d_animation_finished():
	animation.play("flaged")
