extends Node2D

# これまでに出現したモンスターのシーンを代入した変数リスト
const PoisonFlog: PackedScene = preload("res://Scenes/Enemies/poison_flog.tscn")
const GreenFlog: PackedScene = preload("res://Scenes/Enemies/green_flog.tscn")
const PinkFlog: PackedScene = preload("res://Scenes/Enemies/pink_flog.tscn")
const RaccoonDog: PackedScene = preload("res://Scenes/Enemies/raccoon_dog.tscn")
const IceBird: PackedScene = preload("res://Scenes/Enemies/ice_bird.tscn")
const StrikeBird: PackedScene = preload("res://Scenes/Enemies/strike_bird.tscn")

# プログレスバー（どれくらいモンスターが生存するか）
const bar: PackedScene = preload("res://Scenes/life_time_bar.tscn")

var monster: PackedScene
var offset_y = -40
var offset_bird_y = -200

# for test
func _ready():
	decide_monster()
	var monster_summoned = monster.instantiate()
	var bar_summon = bar.instantiate()
	bar_summon.bar_scale = 0.5
	monster_summoned.add_child(bar_summon)
	bar_summon.position.y = offset_y
	if monster == IceBird or monster == StrikeBird:
		monster_summoned.position.y = offset_bird_y
	add_child(monster_summoned)


func decide_monster():
	var i = randi_range(1, 6)

	match i:
		1:
			monster = PoisonFlog
		2:
			monster = GreenFlog
		3:
			monster = PinkFlog
		4:
			monster = RaccoonDog
		5:
			monster = IceBird
		6:
			monster = StrikeBird