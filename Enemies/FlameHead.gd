extends "res://Enemies/BaseEnemy.gd"

const Explosion = preload("res://Animations/Explosion1Animation.tscn")

var undead = true

func take_damage(amount, hit_force = null):
	.take_damage(amount, hit_force)
	if self.hp <= floor(self.max_hp / 4):
		$Sprite.self_modulate = "ff0000"

func attack():
	if self.hp <= 0:
		undead_attack()
	else:
		.attack()

func undead_attack():
	var dialog = show_attack_text("It's blowing up!!!")
	yield(dialog, "done")
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
