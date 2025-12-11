extends Node


# メインメニューとレベルシーンをプリロード
const MAIN_SCENE: PackedScene = preload("res://Scenes/main.tscn")
const LEVEL_SCENE: PackedScene = preload("res://Scenes/stages/level_base.tscn")
const SCENE_01: PackedScene = preload("res://Scenes/stages/tutorial.tscn")
const SCENE_02: PackedScene = preload("res://Scenes/stages/0_2.tscn")
const SCENE_03: PackedScene = preload("res://Scenes/stages/0_3.tscn")
const SCENE_04: PackedScene = preload("res://Scenes/stages/0_4.tscn")
const SCENE_11: PackedScene = preload("res://Scenes/stages/1_1.tscn")
const SCENE_12: PackedScene = preload("res://Scenes/stages/1_2.tscn")
const SCENE_13: PackedScene = preload("res://Scenes/stages/1_3.tscn")
const SCENE_14 = null

var COUNTER_1: int = 0
var COUNTER_2: int = 0

var stageArray = [[SCENE_01, SCENE_02, SCENE_03, SCENE_04],
				[SCENE_11, SCENE_12, SCENE_13, SCENE_14]]

# メインメニューシーンをロードする関数
func load_main_scene():
	get_tree().change_scene_to_packed(MAIN_SCENE)

# レベルシーンをロードする関数
func load_level_scene():
	get_tree().change_scene_to_packed(SCENE_01)

func load_next_level():
	COUNTER_2 += 1

	if COUNTER_2 > 3:
		COUNTER_1 += 1
		COUNTER_2 = 0
	
	get_tree().change_scene_to_packed(stageArray[COUNTER_1][COUNTER_2])
	
func init_counter():
	COUNTER_1 = 0
	COUNTER_2 = 0
