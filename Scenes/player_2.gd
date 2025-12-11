extends CharacterBody2D
class_name Player_2

# プレイヤーの状態を定義
enum PLAYER_STATE {
	IDLE,
	RUN,
	JUMP,
	FALL,
	RESURRECTION,
	DEATH,
}

# 重力の設定
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")

# アニメーションスプライトの参照
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# 移動関連の設定
const MOVESPEED: float = 200.0
@export_group("move")
@export var move_speed: float = MOVESPEED
@export var move_speed_boosted: float = 300.0

# ジャンプ関連の設定
const JUMPFORCE: float = 300.0
@export_group("jump")
@export var jump_force: float = JUMPFORCE # ジャンプ力
@export var jump_force_boosted: float = 450.0
@export var max_y_velocity: float = 400.0 # 最大Y速度
var can_jump: bool = false # ジャンプ可能かどうかのフラグ

var is_boosted: bool = false

# プレイヤーの移動と状態管理
var direction: Vector2 = Vector2.ZERO
var state: PLAYER_STATE = PLAYER_STATE.IDLE # 現在の状態

# 物理処理のメインループ
func _physics_process(delta: float) -> void:
	fallen_off()
	if state != PLAYER_STATE.RESURRECTION and state != PLAYER_STATE.DEATH:
		apply_gravity(delta) # 重力の適用
		get_input() # 入力の取得
		apply_movement(delta) # 移動の適用
		move_and_slide() # スライドしながら移動
		update_state() # 状態の更新
	
# 重力を適用
func apply_gravity(delta: float):
	if !is_on_floor(): # 床に触れていない場合
		velocity.y += GRAVITY * delta
		velocity.y = min(velocity.y, max_y_velocity)

func fallen_off():
	# 一定距離落下した場合にプレイヤーをヒット状態にする
	if global_position.y > 100:
		SignalManager.on_player_2_hit.emit()
		
# プレイヤーの入力を取得
func get_input():
	# 左右移動の入力を取得
	direction.x = Input.get_axis("left_sub", "right_sub")
	
	# ジャンプの入力処理
	if Input.is_action_just_pressed("jump_sub") and is_on_floor():
		can_jump = true
		
# プレイヤーの移動処理
func apply_movement(_delta: float):
	if is_boosted:
		move_speed = move_speed_boosted
		jump_force = jump_force_boosted
	else:
		move_speed = MOVESPEED
		jump_force = JUMPFORCE
		
	if can_jump:
		velocity.y = - jump_force # ジャンプ力を適用
		can_jump = false
	elif direction.x:
		# プレイヤーの向きを左右反転
		animated_sprite_2d.flip_h = direction.x < 0
		velocity.x = direction.x * move_speed # 横方向の移動速度
	else:
		velocity.x = 0 # 横方向の速度をリセット

# プレイヤーの状態を更新
func update_state():
	if state != PLAYER_STATE.RESURRECTION:
		if is_on_floor(): # プレイヤーが地面に触れいている場合
			if velocity.x == 0:
				set_state(PLAYER_STATE.IDLE) # 待機状態
			else:
				set_state(PLAYER_STATE.RUN) # 走行状態
		else:
			if velocity.y > 0:
				set_state(PLAYER_STATE.FALL) # 落下状態
			else:
				set_state(PLAYER_STATE.JUMP) # ジャンプ状態

# プレイヤーの状態を設定
func set_state(new_state: PLAYER_STATE):
	if new_state == state: # 状態が変更されていない場合
		return
	
	state = new_state # 新しい状態に変更
	
	match state: # 状態に応じたアニメーションの再生
		PLAYER_STATE.IDLE:
			animated_sprite_2d.play("idle")
		PLAYER_STATE.RUN:
			animated_sprite_2d.play("run")
		PLAYER_STATE.JUMP:
			animated_sprite_2d.play("jump")
		PLAYER_STATE.FALL:
			animated_sprite_2d.play("fall")
		PLAYER_STATE.RESURRECTION:
			animated_sprite_2d.play("resurrection")
		PLAYER_STATE.DEATH:
			animated_sprite_2d.play("death")
		
func resurrection():
	set_state(PLAYER_STATE.RESURRECTION)

func die():
	queue_free()

func ready_die():
	set_state(PLAYER_STATE.DEATH)


func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("trap"):
		velocity = Vector2.ZERO
		SignalManager.on_player_2_hit.emit()
	if area.is_in_group("pink"):
		area.get_parent().death()
		
# プレイヤー同士が近くにいる時に発生するモードで、バフがかかる。
func boosted():
	is_boosted = true
	
func unboosted():
	is_boosted = false
	
func _on_animated_sprite_2d_animation_finished():
	if state == PLAYER_STATE.RESURRECTION:
		state = PLAYER_STATE.IDLE
		animated_sprite_2d.play("idle")
	elif state == PLAYER_STATE.DEATH:
		die()
