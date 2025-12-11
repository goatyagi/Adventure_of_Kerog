extends CharacterBody2D


enum STATE {
	IDLE,
	ATTACK,
	ATTACK2,
	SUMMON,
	MOVE,
}

const JUMP_VELOCITY = -400.0

const Summon_Collection: PackedScene = preload("res://Scenes/Enemies/summoned_collection.tscn")

@onready var timer: Timer = $ChangeStateTimer
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_head: Area2D = $Collision_for_head
@onready var collision_body: Area2D = $Collision_for_body
@onready var pos_summon = $SummonPoint

@export var duration_time = 1
@export var back_height = 1000
@export var pos_attack2 = Vector2(0, 0)
@export var speed = 150.0
@export var move_stop_point_x = 0

var state = STATE.IDLE
var is_encounted = false
var gravity = 500

var start_position
var end_position

var tween: Tween

var is_back = false
var test_flag = false
var is_attack1 = false
var is_attack2 = false

func _ready():
	end_position = global_position
	SignalManager.on_boss_hit.connect(Callable(self, "_on_hit"))


func _physics_process(_delta):
	manage_animation()

	if not is_on_floor():
		self.velocity.y += gravity * _delta

	if state == STATE.MOVE:
		move()
		move_and_slide()

	if state == STATE.IDLE:
		if timer.is_stopped():
			timer.start()
	

func decide_action():
	var i = randi_range(1, 5)
	print(i)

	match i:
		1:
			state = STATE.IDLE
		2:
			state = STATE.ATTACK
			attack1()
		3:
			state = STATE.ATTACK2
			attack2()
		4:
			state = STATE.SUMMON
		5:
			state = STATE.MOVE

func manage_animation():
	match state:
		STATE.IDLE:
			animation.play("idle")
		STATE.ATTACK:
			animation.play("attack")
		STATE.ATTACK2:
			animation.play("attack2")
		STATE.SUMMON:
			animation.play("summon")
		STATE.MOVE:
			animation.play("idle")

func move():
	if move_stop_point_x < self.position.x:
		self.velocity.x = - speed
	else:
		state = STATE.IDLE
		back_to_start()

# 首を伸ばして攻撃するモーション
func attack1():
	if tween:
		tween.kill()
	tween = create_tween()

	tween.tween_property(collision_head, "rotation", deg_to_rad(-90), 0.25)
	tween.parallel().tween_property(collision_head, "position", Vector2(-345, 600), 0.375)
	tween.parallel().tween_property(collision_body, "position", Vector2(collision_body.position.x, 600), 0.375)
	tween.parallel().tween_property(self, "position", Vector2(self.position.x, self.position.y + 20), 0.1)
	tween.parallel().tween_property(collision_head, "rotation", deg_to_rad(0), 0.25).set_delay(0.375)
	tween.parallel().tween_property(collision_head, "position", Vector2(340, 430), 0.375).set_delay(0.375)
	tween.parallel().tween_property(collision_body, "position", Vector2(465, 724), 0.375).set_delay(0.375)
	tween.parallel().tween_property(self, "position", Vector2(self.position.x, self.position.y - 1), 0.1).set_delay(0.375)
	tween.tween_callback(Callable(timer, "start"))

func attack2():
	start_position = Vector2(global_position.x, global_position.y + 20)
	if tween:
		tween.kill()
	tween = create_tween()

	# コリジョンの位置調整
	tween.tween_property(collision_head, "rotation", deg_to_rad(-90), 0.01)
	tween.parallel().tween_property(collision_head, "position", Vector2(-345, 600), 0.01)
	tween.parallel().tween_property(collision_body, "position", Vector2(collision_body.position.x, 600), 0.01)
	# tween.tween_property(self, "global_position", Vector2(self.position.x, self.position.y + 100), 0.01)
	# ここからtween.paralell().tween_method()で直進操作を作る
	tween.tween_method(
		Callable(self, "_move_to_left"),
		0.0,
		1.0,
		duration_time
	).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	# 元の状態に戻す処理
	tween.tween_property(collision_head, "rotation", deg_to_rad(0), 0.01)
	tween.parallel().tween_property(collision_head, "position", Vector2(340, 430), 0.01)
	tween.parallel().tween_property(collision_body, "position", Vector2(465, 724), 0.5)
	tween.tween_callback(Callable(self, "back_to_start"))

func _move_to_left(t: float):
	var pos = start_position.lerp(pos_attack2, t)
	global_position = pos

func summon():
	var summon_monster = Summon_Collection.instantiate()
	summon_monster.position = pos_summon.global_position
	add_sibling(summon_monster)
	state = STATE.IDLE

# この関数は、あるアクションを行なった後に定位置に戻ることで、へんな挙動を防ぐためのものである。
# 具体的には、アクション終了後にback_to_startを呼び出すことで、終了時のポジションから初期位置に放物線を描きながら戻っていくというものである。
func back_to_start(start_pos = global_position):
	state = STATE.IDLE
	is_back = true
	start_position = start_pos
	if tween:
		tween.kill()
	
	tween = create_tween()

	tween.tween_method(
		Callable(self, "_move_along_parabola"),
		0.0,
		1.0,
		duration_time
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(Callable(timer, "start"))

func _move_along_parabola(t: float):
	# 線形補間でx,yを作る
	var pos = start_position.lerp(end_position, t)

	# 放物線の高さ（最大高さを与えて、放物線形にy座標を上下させる。)
	var height = -4 * back_height * t * (t - 1)
	pos.y -= height

	global_position = pos

func _on_change_state_timer_timeout():
	decide_action()

func _on_animated_sprite_2d_animation_finished():
	if state == STATE.ATTACK:
		state = STATE.IDLE
		# is_attack1 = false
	if state == STATE.SUMMON:
		summon()

func _on_hit():
	back_to_start(Vector2(global_position.x - 100, global_position.y))