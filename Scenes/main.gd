extends Node2D

func _ready() -> void:
	GameManager.init_counter()
	get_tree().paused = false # メニュー画面が表示される時、ゲームの一時停止を解除する。

func _process(_delta: float) -> void:
	# スペースキーが押されたらStartのログを出力
	if Input.is_action_just_pressed("start"):
		GameManager.load_level_scene()
		print("Start")
