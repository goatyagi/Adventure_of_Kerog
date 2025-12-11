extends StaticBody2D

# プレイヤーのリスポーン位置を指定するマーカー
@onready var marker_2d: Marker2D = $Marker2D
@onready var respawnTimer_1: Timer = $Timer
@onready var respawnTimer_2: Timer = $Timer2
@export var player_scene: PackedScene
@export var player_2scene: PackedScene

# プレイヤーへの参照
var player: Player
var player_2: Player_2

var default_marker_pos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# プレイヤーのノードを取得
	player = get_tree().get_first_node_in_group("player")
	player_2 = get_tree().get_first_node_in_group("player_2")
	default_marker_pos = self.position
	# プレイヤーがダメージを受けた時のシグナルに接続
	SignalManager.on_player_hit.connect(_on_player_hit)
	SignalManager.on_player_2_hit.connect(_on_player_2_hit)
	SignalManager.on_checkpoint.connect(change_respawn_position)
	
# プレイヤーがダメージを受けた時に呼ばれる関数
func _on_player_hit():
	player.ready_die()
	respawnTimer_1.start()

func _on_player_2_hit():
	player_2.ready_die()
	respawnTimer_2.start()

func _on_timer_timeout():
	var new_player = player_scene.instantiate()
	player = new_player
	add_sibling(player)
	player.resurrection()
	player.global_position = marker_2d.global_position
	player.animated_sprite_2d.flip_h = false

func _on_timer_2_timeout():
	var new_player_2 = player_2scene.instantiate()
	player_2 = new_player_2
	add_sibling(player_2)
	player_2.resurrection()
	player_2.global_position = marker_2d.global_position
	player_2.animated_sprite_2d.flip_h = false

func change_respawn_position(pos):
	marker_2d.position = pos - default_marker_pos
	print(pos)
	print(default_marker_pos)
