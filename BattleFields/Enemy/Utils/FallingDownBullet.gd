extends Area2D

const RIGHT = Vector2(1, 0)
var direction = RIGHT
var speed = 50
var hit = false
signal hit

onready var animationPlayer = $AnimationPlayer
onready var explodeSFX = $ExplodeSFX

func _ready():
	if direction == RIGHT:
		self.rotation_degrees = 180
	animationPlayer.connect("animation_finished", self, "on_animationPlayer_animation_finished")

func _physics_process(delta):
	if not hit:
		self.position += direction * speed * delta


func _on_Bullet_body_entered(_body):
	if not hit:
		hit = true
		emit_signal("hit")
		explodeSFX.play()
		animationPlayer.play("Explode")

func on_animationPlayer_animation_finished(_anim_name):
	queue_free()
