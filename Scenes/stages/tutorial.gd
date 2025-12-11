extends Node2D

@onready var player: Player = self.find_child("Player")
@onready var camera: Camera2D = self.find_child("Camera")
@onready var goal = self.find_child("Goal")

var pos_camera
var pos_player
var distance


func _ready() -> void:
	get_tree().paused = false # ゲームを開始する際には一時停止を解除
	pos_camera = camera.position
	pos_player = player.position
	distance = pos_camera.x - pos_player.x
	goal.goal_2 = true
	
func _process(_delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	
	if player != null:
		camera.position.x = player.position.x + distance
