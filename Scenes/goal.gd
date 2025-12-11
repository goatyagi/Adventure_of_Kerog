extends Area2D

var goal_1 = false
var goal_2 = false

@onready var label: Label = $"Control/Label"

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = ""
	hide_label()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_area_entered(area):
	if area.get_parent() is Player:
		goal_1 = true
		label.text = "1/2"
		show_label()
	elif area.get_parent() is Player_2:
		goal_2 = true
		label.text = "1/2"
		show_label()
	
	if goal_1 and goal_2:
		SignalManager.on_game_complete.emit()
		label.text = "Complete!"
		print("Goal")


func _on_area_exited(area):
	if area.get_parent() is Player:
		goal_1 = false
		hide_label()
	elif area.get_parent() is Player_2:
		goal_2 = false
		hide_label()
		
func show_label():
	label.visible = true
	
func hide_label():
	label.visible = false
