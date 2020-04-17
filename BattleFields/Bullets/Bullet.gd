extends Area2D

signal hit(target, position)
signal point_reached(bullet)
var direction = Vector2(0, 1) # Down
var base_speed = 50
var speed_multiplier = 1
var paused = false
var stop_point = null
var color = "ffffff" setget set_color

func set_color(new_color):
	color = new_color
	$ColorRect.color = new_color

func _physics_process(delta):
	if not paused:
		var speed = base_speed * speed_multiplier
		self.position += direction * speed * delta
		if stop_point and self.position.y  >= stop_point:
			stop_point = null
			emit_signal("point_reached", self)

func _on_Bullet_area_entered(area):
	emit_signal("hit", area, self.position)
	queue_free()

func pause():
	paused = true

func unpause():
	paused = false
