extends Node2D

@onready var power: Area2D = self.find_child("Power")
@onready var goal: Area2D = self.find_child("Goal")
@onready var animation: AnimationPlayer = $AnimationPlayer

func _on_power_body_entered(_body):
	animation.play("typing")
	power.queue_free()
	
func _on_goal_body_entered(_body):
	animation.play("typing_goal")
	goal.queue_free()
