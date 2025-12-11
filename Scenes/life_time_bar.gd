extends TextureProgressBar

# プログレスバーを取得する
@onready var bar: TextureProgressBar = $TextureProgressBar
@export var progress_time: float = 5
@export var bar_scale: float = 1

@onready var tween: Tween

func _ready():
	self.scale = Vector2(self.scale.x * bar_scale, self.scale.y * bar_scale)
	max_value = 100
	min_value = 0
	value = 100 # 初期値を設定する。

	start_progress_animation(0, 5.0)

func start_progress_animation(target_value: float, duration: float):
	if tween:
		tween.kill()

	tween = create_tween()
	tween.finished.connect(_on_tween_finished)
	tween.tween_property(self, "value", target_value, duration)

# 本来であれば、summoned_collection自体に実装すべきであるqueue_free()であるが、
# そうすると、仮に二体以上召喚されたモンスターがいた時に、まだ制限時間の残っている
# モンスターまで同時にqueue_free()されてしまうという問題が発生した。
# その解決のため、シグナルを使ってqueue_free()を管理するのではなく、階層構造を利用
# して、life_time_barのtweenが終了したタイミングで、life_time_barの親を消すように
func _on_tween_finished():
	get_parent().queue_free()
