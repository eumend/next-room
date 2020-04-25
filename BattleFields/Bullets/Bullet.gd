extends Area2D

signal hit(target, position)
var direction = Vector2(0, 1) # Down
var speed = 50
var paused = false
var stop_point = null
var stop_point_time = null
var color = "ffffff" setget set_color
onready var animationPlayer = $AnimationPlayer
onready var stopPointTimer = $StopPointTimer

func _ready():
	stopPointTimer.connect("timeout", self, "on_stopPointTimer_timeout")

func set_color(new_color):
	color = new_color
	$ColorRect.color = new_color

func _physics_process(delta):
	if not paused:
		self.position += direction * speed * delta
		if stop_point and stop_point_time and self.position.y  >= stop_point:
			self.pause()
			stopPointTimer.wait_time = stop_point_time
			stopPointTimer.start()
			stop_point = null
			stop_point_time = null

func on_stopPointTimer_timeout():
	self.unpause()

func _on_Bullet_area_entered(area):
	if not paused: # FIXME: For some reason it keeps firing this event after hitting one time, even though it should not be moving anymore. This is a workaround to only detect once.
		paused = true
		emit_signal("hit", area, self)

func pause():
	paused = true

func unpause():
	paused = false

func disappear():
	paused = true
	animationPlayer.play("Disappear")

func explode():
	paused = true
	animationPlayer.play("Explode")

func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
