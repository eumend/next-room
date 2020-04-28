extends Node2D

signal died
signal hit(area, bullet)
signal hp_changed(hp)

onready var animationPlayer = $AnimationPlayer
onready var explodeSFX = $ExplodeSFX
onready var hitSFX = $HitSFX
onready var sprite = $Sprite

var direction = Vector2(0, 1) # Down
var speed = 100
var paused = false
var hp = 3
var boss_sprite = null setget set_boss_sprite

func _ready():
	animationPlayer.connect("animation_finished", self, "_on_animationPlayer_animation_finished")
	pass # Replace with function body.

func _physics_process(delta):
	if not paused:
		self.position += direction * speed * delta

func take_hit():
	hp -= 1
	emit_signal("hp_changed", hp)
	if hp == 0:
		paused = true
		animationPlayer.play("Explode")
		explodeSFX.play()
	else:
		animationPlayer.play("Hit")
		hitSFX.play()
		speed = speed * 1.2

func _on_animationPlayer_animation_finished(anim_name):
	if anim_name == "Explode":
		emit_signal("died")
		queue_free()

func _on_BossBullet_area_entered(area):
	emit_signal("hit", area, self)

func set_boss_sprite(new_sprite):
	sprite.texture = new_sprite
