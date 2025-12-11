extends RigidBody2D

class_name Flog

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_timer: Timer = $StateTimer

@export var speed = 100.0

var state = STATE.IDLE
var direction = -1.0

var pos_now = 0
var pos_before = 0

enum STATE {
	IDLE,
	ROLL,
	WALK,
	RUN,
	DEATH,
}

func _ready():
	pos_before = position.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if state != STATE.DEATH:
		move()

func _on_timer_timeout():
	if state != STATE.DEATH:
		decide_state()
		state_timer.wait_time = randi_range(1, 3)

	
func _on_pos_check_timer_timeout():
	if state != STATE.DEATH:
		pos_now = int(position.x)
		
		if state != STATE.IDLE:
			if pos_now == pos_before:
				change_direction()
			else:
				pos_before = pos_now
				pos_now = 0
			
	
func decide_state():
	var i = randi_range(1, 4)
	
	match i:
		1:
			state = STATE.IDLE
		2:
			state = STATE.ROLL
		3:
			state = STATE.WALK
		4:
			state = STATE.RUN

func move():
	match state:
		STATE.IDLE:
			speed = 0.0
			animation.play("idle")
		STATE.ROLL:
			speed = 150.0
			animation.play("roll")
		STATE.WALK:
			speed = 100.0
			animation.play("walk")
		STATE.RUN:
			speed = 200.0
			animation.play("run")
	
	self.linear_velocity.x = speed * direction

func change_direction():
	animation.flip_h = !animation.flip_h
	direction = - direction
