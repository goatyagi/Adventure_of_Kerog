extends Flog

@onready var hitbox: Area2D = $HitBox
@onready var deathTimer: Timer = $DeathTimer


func death():
	if state != STATE.DEATH:
		deathTimer.start()
		hitbox.remove_from_group("trap")
		animation.play("death")
		state = STATE.DEATH
		direction = 0
		
func _on_green_flog_hit():
	death()


func _on_death_timer_timeout():
	queue_free()
