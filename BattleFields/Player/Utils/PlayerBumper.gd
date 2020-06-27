extends Area2D

var direction = 1
var speed = 0
var moving = true
signal hit
onready var animationPlayer = $AnimationPlayer

func _physics_process(delta):
	if moving:
		var motion = Vector2(direction, 0)
		self.position += motion * delta * speed

func disappear():
	moving = false
	animationPlayer.play("Disappear")

func explode():
	moving = false
	animationPlayer.play("Explode")

func check_overlap(zone_area):
	if overlaps_area(zone_area):
		emit_signal("hit")
		explode()


func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
