extends Node2D

@onready var body: RigidBody2D = $RigidBody2D
var is_falling
var position_init
var num_count: int = 0
@export var move_speed = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	position_init = body.position
	is_falling = false
	
func _physics_process(delta):
	if is_falling:
		body.linear_velocity.y += 0.5 * num_count * move_speed * delta
	elif !is_falling && body.position.y > position_init.y:
		body.linear_velocity.y += -move_speed * delta
	else:
		body.linear_velocity.y = 0.0
		body.position.y = position_init.y


func _on_detection_area_body_entered(_body):
	num_count += 1
	is_falling = true

func _on_detection_area_body_exited(_body):
	num_count -= 1
	is_falling = false
