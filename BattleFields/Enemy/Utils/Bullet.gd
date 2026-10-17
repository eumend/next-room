extends Area2D

signal hit(target, position)
var direction = Vector2(0, 1) # Down
var speed = 50
var paused = false
var has_hit = false
var color = "ffffff" setget set_color
onready var animationPlayer = $AnimationPlayer
signal unpaused

func set_color(new_color):
	color = new_color
	$ColorRect.color = new_color

func _physics_process(delta):
	if not paused:
		self.position += direction * speed * delta

func _on_Bullet_area_entered(area):
	# Only report the first hit. Kept apart from 'paused' so a bullet parked
	# at its stop point (StopBullet) still hits a player that moves under it.
	if not has_hit:
		has_hit = true
		paused = true
		emit_signal("hit", area, self)

func pause():
	paused = true

func unpause():
	paused = false
	emit_signal("unpaused")

func disappear():
	paused = true
	animationPlayer.play("Disappear")

func explode():
	paused = true
	animationPlayer.play("Explode")

func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
