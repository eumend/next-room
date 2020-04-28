extends "res://Enemies/BaseEnemy.gd"

const Explosion = preload("res://Animations/Explosion1Animation.tscn")

var undead = true

func attack():
	if self.hp <= 0:
		undead_attack()
	else:
		.attack()

func undead_attack():
	DialogBox.show_timeout("KAMIKAZE!", 1)
	yield(DialogBox, "done")
	animate_explosion()

func is_dead():
	return .is_dead() and not undead

func _on_Explosion_animation_finished():
	undead = false
	.on_death()

func _on_Explosion_animation_boom():
	self.hide()
	.deal_damage(GameConstants.HIT_FORCE.CRIT, self.power * 2)

func animate_explosion():
	var explosion = Explosion.instance()
	var main = get_tree().current_scene
	main.add_child(explosion)
	explosion.connect("boom", self, "_on_Explosion_animation_boom")
	explosion.connect("done", self, "_on_Explosion_animation_finished")
	explosion.global_position = $Sprite.global_position
