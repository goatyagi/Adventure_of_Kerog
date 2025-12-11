extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

@export var speed = 200.0
@export var gravity = 500.0
var direction = 0.0
var state = STATE.IDLE
var player
var player_2
var detected = false
var response_distance = 10
var is_grounded = false

enum STATE {
	IDLE,
	RUN,
}


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	manage_animation()
	
	if not is_on_floor():
		self.velocity.y += gravity * delta
	
	if detected and is_on_floor():
		direction = get_direction(player.position.x)
		self.velocity.x = speed * direction
		animation.flip_h = direction < 0
	else:
		self.velocity.x = 0
	
	move_and_slide()

func _on_detect_area_body_entered(body):
	if (body.is_in_group("player") or body.is_in_group("player_2")):
		if player == null:
			player = body
			detected = true
			state = STATE.RUN
		else:
			player_2 = body
		
func get_direction(player_position_x):
	if (player_position_x - global_position.x) < -response_distance:
		return -1.0
	elif (player_position_x - global_position.x) > response_distance:
		return 1.0
	else:
		return 0.0

func manage_animation():
	if state == STATE.IDLE:
		animation.play("idle")
	elif state == STATE.RUN:
		animation.play("run")


func _on_detect_area_body_exited(body):
	if (body == player):
		if player_2 == null:
			player = null
			detected = false
			state = STATE.IDLE
		else:
			player = player_2
			player_2 = null
	elif (body == player_2):
		player_2 = null

func _on_is_grounded_body_entered(_body):
	is_grounded = true

func _on_is_grounded_body_exited(_body):
	is_grounded = false
