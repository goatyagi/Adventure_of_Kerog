extends Bird

@onready var ball_scene: PackedScene = preload('res://Scenes/Enemies/ice_ball.tscn')
@onready var shot_point: Marker2D = $ShotPoint

@export var shot_speed: float = 100
# ここで、attackしたタイミングでプレイヤーが片方いなくなっていたら、一旦can_attackをfalseに変更
# そうすることで、プレイヤーが離れたところにいる場合に、攻撃を周期的に行いながら近づく不穏な行動を制限できる。
func attack():
	var ice_ball = ball_scene.instantiate()
	var target_ball_pos = Vector2(target.position.x + randf_range(-30, 30), target.position.y) # 少し誤差があった方が、面白いと思ったので、randf_rangeで+-30の誤差を追加

	ice_ball.position = shot_point.global_position
	ice_ball.linear_velocity = (target_ball_pos - shot_point.global_position).normalized() * shot_speed

	set_state(BIRD_STATE.ATTACK)
	add_sibling(ice_ball)


func handle_attack():
	move()
