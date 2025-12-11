extends RigidBody2D

@onready var sprite_2d: Sprite2D = $"Sprite2D"
@onready var hitbox: CollisionShape2D = $"DetectArea/CollisionShape2D"
@onready var timer: Timer = $"InvincibleTimer"

@export var ball_blue: CompressedTexture2D = preload("res://assets/ball_blue.png")
@export var ball_green: CompressedTexture2D = preload("res://assets/ball_green.png")
@export var ball_yellow: CompressedTexture2D = preload("res://assets/ball_yellow.png")
@export var ball_red: CompressedTexture2D = preload("res://assets/ball_red.png")

@export var scroll_speed = 5

# i=0: => blue
# i=1: => green
# i=2: => yellow
# i=3: => red
# if i=4 and hit ball then kill boss
var i = 0 # count 変数
var ball_colors = []

var blinking = false

func _ready() -> void:
	# 背景画像のテクスチャを設定
	ball_colors = [ball_blue, ball_green, ball_yellow, ball_red]
	sprite_2d.texture = ball_colors[i]
	i += 1

func _process(_delta):
	if blinking: sprite_2d.visible = int(Engine.get_physics_frames() * 5) % 2 == 0 # 点滅処理：1秒間に5回点滅（0.2秒周期）
	else: sprite_2d.visible = true # 点滅していないときは常に表示

func change_color():
	sprite_2d.texture = ball_colors[i]
	i += 1

func _on_detect_area_body_entered(body: Node2D):
	if body.is_in_group("player") or body.is_in_group("player_2"):
		if blinking or i == 4:
			if i == 4:
				print("dead!")
		else:
			blinking = true
			hitbox.disabled = true # コリジョン無効化
			timer.start()
			SignalManager.on_boss_hit.emit()
			change_color()


func _on_invincible_timer_timeout():
	blinking = false
	hitbox.disabled = false
