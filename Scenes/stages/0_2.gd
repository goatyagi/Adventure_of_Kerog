extends Node2D

@onready var player: Player = self.find_child("Player")
@onready var player_2: Player_2 = self.find_child("Player2")
@onready var camera: Camera2D = self.find_child("Camera")

@onready var _animation: AnimationPlayer = self.find_child("AnimationPlayer")


var pos_camera
var pos_player
var pos_player_2
var distance

enum CAMERA_MODE {
	GREEN,
	PINK,
}

var mode: CAMERA_MODE = CAMERA_MODE.GREEN

func _ready() -> void:
	get_tree().paused = false # ゲームを開始する際には一時停止を解除
	pos_camera = camera.position
	pos_player = player.position
	distance = pos_camera.x - pos_player.x
	
func _process(_delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	if player_2 == null:
		player_2 = get_tree().get_first_node_in_group("player_2")

	if Input.is_action_just_pressed("camera_mode_change"):
		change_mode(mode)
			
	if (mode == CAMERA_MODE.GREEN and player != null):
		camera.position.x = player.position.x + distance
	elif (mode == CAMERA_MODE.PINK and player != null):
		camera.position.x = player_2.position.x + distance
	
func change_mode(current_mode):
	if (current_mode == CAMERA_MODE.GREEN):
		mode = CAMERA_MODE.PINK
	elif (current_mode == CAMERA_MODE.PINK):
		mode = CAMERA_MODE.GREEN

func _on_kinds_area_body_entered(_body):
	_animation.play("typing_kinds")
