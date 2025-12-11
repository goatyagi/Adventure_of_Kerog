extends CharacterBody2D

class_name Bird

enum BIRD_STATE {
	IDLE,
	MOVE,
	ATTACK,
}

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $AttackTimer

@export var speed = 300
@export var attack_speed = 400
@export var response_distance = 50
@export var attack_wait_time = 1.5
@export_range(0, 1) var smooth_rotation = 0.05


var state = BIRD_STATE.IDLE
var player
var player_2
var target

var direction = 0 # 動く方向、1: 右　-1: 左

# 攻撃用の変数
var attack_target_position: Vector2
var return_position: Vector2
var is_returning = false
var can_attack = false
var is_timer = false

func _ready():
	player = get_tree().get_first_node_in_group("player")
	player_2 = get_tree().get_first_node_in_group("player_2")
	timer.wait_time = attack_wait_time
	decide_target()

func _physics_process(_delta):
	decide_target()

	# プレイヤーが死んでからリスポーンするまでの間、player, player_2はシーンに存在しないので、見つかるまでplayerを探索してくれるようにしている。
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	if player_2 == null:
		player_2 = get_tree().get_first_node_in_group("player_2")
	
	
	match state:
		BIRD_STATE.ATTACK:
			handle_attack()
		_:
			if target != null: # targetがいないというときは、player, player_2が両方とも死んでいるタイミングである。
				move()

	move_and_slide()
	

# set_stateはstateの管理を簡単にするためのもので、stateの切り替え時にこの関数を使うことで、アニメーションの変遷も同時に行えるようにしている。
func set_state(new_state):
	if state == new_state:
		pass
	else:
		state = new_state

	match state:
		BIRD_STATE.IDLE:
			animation.play("idle")
		BIRD_STATE.MOVE:
			animation.play("move")
		BIRD_STATE.ATTACK:
			animation.play("attack")

# decide_target()関数は、距離が近いプレイヤーをtargetに指定する関数である。
func decide_target():
	# もし両方ともプレイヤーが死んでいるタイミングなら、targetもnullにする。
	if player == null and player_2 == null:
		target = null
		can_attack = false

	# もし、両方ともnullではなければ、距離が近い方をtargetとして指定している。
	if player != null and player_2 != null:
		var distance_p1 = global_position - player.position
		var distance_p2 = global_position - player_2.position
		if distance_p1.length() < distance_p2.length():
			target = player
		else:
			target = player_2
	# 注意点：遠い方のplayerが死んでいる間は、targetが不在になってしまうような条件定義になっているが、
	# 		今のところ、動作に支障はないので実装していない。


func _on_attack_timer_timeout():
	if target != null and can_attack and state != BIRD_STATE.ATTACK:
		attack()
		timer.stop()
		is_timer = false


# ここで、attackしたタイミングでプレイヤーが片方いなくなっていたら、一旦can_attackをfalseに変更
# そうすることで、プレイヤーが離れたところにいる場合に、攻撃を周期的に行いながら近づく不穏な行動を制限できる。
func attack():
	# 現在位置（戻るための位置）とターゲットのY位置をもとに攻撃地点を決定
	attack_target_position = target.position
	return_position = global_position # 今いる場所を戻る場所として記録する。

	set_state(BIRD_STATE.ATTACK)

	# 突進の方向ベクトルを計算
	var direction_vector = (attack_target_position - global_position).normalized()
	velocity = direction_vector * attack_speed


func handle_attack():
	if !is_returning:
		# 攻撃地点に十分近づいたら、戻るフェーズへ移行
		if global_position.distance_to(attack_target_position) < 10:
			is_returning = true
			var return_dir = (return_position - global_position).normalized()
			velocity.y = return_dir.y * attack_speed
	else:
		# 戻る位置に着いたら終了
		if - (return_position.y - global_position.y) < 1:
			set_state(BIRD_STATE.IDLE)
			is_returning = false
			is_timer = false
			can_attack = false
			velocity = Vector2.ZERO

	var target_angle

	if animation.flip_h:
		target_angle = velocity.angle()
	else:
		target_angle = - velocity.angle()
	rotation = lerp_angle(rotation, target_angle, smooth_rotation)
	

'''
	move()関数は、鳥の動きを管理するための関数である。
	targetが存在する（nullではない)時に、target方向に進み、その方向を向くようにanimation.flip_hを管理している。
'''
func move():
	get_direction()
	self.velocity.x = speed * direction
	animation.flip_h = direction > 0
	rotation = 0

'''
	get_directionでは、鳥とtargetの距離関係をもとに、進むべき方向を指定する関数である。
	方向の決定は主に三段階で場合分けをしている。
	また、response_distanceの範囲にいるときは、鳥がtargetに十分近いものとし、攻撃可能のcan_attackフラグをオンにしておく。
	1. target-response_distanceよりも左に鳥がいる場合
		targetに近づく方向、つまり右方向にdirection(=1)を設定
	2. target+response_distanceよりも右に鳥がいる場合
		targetに近づく方向、つまり左方向にdirection(=-1)を設定
	3. target+-response_distanceの間に鳥がいる場合
		can_attack = true
'''
func get_direction():
	if (global_position.x - target.position.x) < -response_distance:
		set_state(BIRD_STATE.MOVE)
		direction = 1.0
	elif (global_position.x - target.position.x) > response_distance:
		set_state(BIRD_STATE.MOVE)
		direction = -1.0
	else:
		set_state(BIRD_STATE.IDLE)
		can_attack = true # can_attackはこの状態の時に十分に近いと考え、can_attack はtrueとする。
		
		if !is_timer:
			timer.start()
			is_timer = true


func _on_hitbox_body_entered(_body: Node2D):
	if state == BIRD_STATE.ATTACK:
		is_returning = true
		var return_dir = (return_position - global_position).normalized()
		velocity.y = return_dir.y * attack_speed
