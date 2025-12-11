extends RigidBody2D

class_name ball

@onready var animation = $AnimationPlayer

func _on_animation_player_animation_finished(_anim_name: StringName):
	queue_free()


func _on_area_2d_body_entered(_body: Node2D):
	animation.play("spread")
	linear_velocity = Vector2.ZERO
