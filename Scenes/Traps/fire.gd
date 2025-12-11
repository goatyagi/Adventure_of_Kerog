extends Node2D

@onready var timer_on: Timer = self.find_child("Timer_on")
@onready var timer_off: Timer = self.find_child("Timer_off")
@onready var collision: CollisionShape2D = $FireArea/CollisionShape2D
@onready var animation: AnimatedSprite2D = self.find_child("AnimatedSprite2D")


func _on_timer_on_timeout():
	animation.play("switch")
	# animation.play("fire")
	timer_off.start()


func _on_timer_off_timeout():
	animation.play("off")
	collision.set_disabled(true)
	timer_on.start()

func _on_animated_sprite_2d_animation_finished():
	animation.play("fire")
	collision.set_disabled(false)
