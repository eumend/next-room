extends Area2D

signal hit(target, position)
signal explode
signal disappear
var direction = Vector2(0, 1) # Down
var speed = 100
var paused = false
var color = "ffffff" setget set_color
var time_seconds = 3
var base_countdown_animation_speed = 1
var bullet_type = GameConstants.BOMB_BULLET_TYPES.COUNTDOWN
onready var animationPlayer = $AnimationPlayer
onready var countdownTimer = $CountdownTimer
onready var explodeSFX = $ExplodeSFX
onready var disappearSFX = $DisappearSFX

func _ready():
	countdownTimer.wait_time = time_seconds
	var speed_for_countdown = float(base_countdown_animation_speed) / time_seconds
	animationPlayer.playback_speed = speed_for_countdown
	if bullet_type == GameConstants.BOMB_BULLET_TYPES.COUNTDOWN:
		animationPlayer.play("Countdown")
	else:
		animationPlayer.play("Cooldown")
	countdownTimer.start()
	countdownTimer.connect("timeout", self, "_on_countdownTimer_timeout")

func set_color(new_color):
	color = new_color
	$Sprite.color = new_color

func _physics_process(delta):
	if not paused:
		self.position += direction * speed * delta

func pause():
	paused = true

func unpause():
	paused = false

func disappear():
	paused = true
	emit_signal("disappear", bullet_type)
	animationPlayer.playback_speed = 1
	animationPlayer.play("Disappear")
	disappearSFX.play()
#
func explode():
	paused = true
	emit_signal("explode")
	animationPlayer.playback_speed = 1
	animationPlayer.play("Explode")
	explodeSFX.play()

func _on_countdownTimer_timeout():
	if not paused:
		if bullet_type == GameConstants.BOMB_BULLET_TYPES.COUNTDOWN:
			self.explode()
		else:
			self.disappear()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Explode" or anim_name == "Disappear":
		queue_free()

func _on_BombBullet_area_entered(area):
	emit_signal("hit", area, self)
#	if not paused: # FIXME: For some reason it keeps firing this event after hitting one time, even though it should not be moving anymore. This is a workaround to only detect once.
#		paused = true
