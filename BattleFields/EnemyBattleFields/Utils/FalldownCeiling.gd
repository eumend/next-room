extends KinematicBody2D

export var direction = Vector2(0, 1)
var speed = 0
export var can_kill = true setget set_can_kill

onready var impulseTimer = $ImpulseTimer
onready var sprite = $Sprite

func set_can_kill(new_can_kill):
	can_kill = new_can_kill
	if can_kill:
		sprite.color = "fa0303"
	else:
		sprite.color = "00f9ff"

func _ready():
	impulseTimer.connect("timeout", self, "on_impulseTimer_timeout")

func move(new_speed, time):
	speed = new_speed
	impulseTimer.wait_time = time
	impulseTimer.start()

func on_impulseTimer_timeout():
	speed = 0

func _physics_process(delta):
	if speed > 0:
		var movement_vector = direction.normalized() * speed * delta
		var _moved = self.move_and_collide(movement_vector)
