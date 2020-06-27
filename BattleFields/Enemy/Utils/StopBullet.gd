extends "res://BattleFields/Enemy/Utils/Bullet.gd"

var stop_point = null
var stop_point_time = null
onready var stopPointTimer = $StopPointTimer
onready var spriteAnimationPlayer = $SpriteAnimationPlayer
onready var spriteNode = $Sprite
var sprite = null

func _ready():
	if sprite:
		spriteNode.texture = sprite
	stopPointTimer.connect("timeout", self, "on_stopPointTimer_timeout")
	spriteAnimationPlayer.connect("animation_finished", self, "_on_SpriteAnimationPlayer_animation_finished")

func _physics_process(delta):
	if not paused:
		self.position += direction * speed * delta
		if stop_point and stop_point_time and self.position.y  >= stop_point:
			self.pause()
			stopPointTimer.wait_time = stop_point_time
			stopPointTimer.start()
			stop_point = null
			stop_point_time = null

func disappear():
	paused = true
	spriteAnimationPlayer.play("Disappear")

func explode():
	paused = true
	spriteAnimationPlayer.play("Explode")

func on_stopPointTimer_timeout():
	self.unpause()


func _on_SpriteAnimationPlayer_animation_finished(_anim_name):
	queue_free()
