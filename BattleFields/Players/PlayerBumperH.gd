extends Area2D

var direction = 1
var speed = 0
var paused = true

func start():
	paused = false

func stop():
	paused = true

func change_direction():
	direction = 1 if direction == -1 else -1

func _physics_process(delta):
	if not paused:
		var motion = Vector2(direction, 0)
		self.position += motion * delta * speed
