extends Area2D

signal hit(target, position)
var direction = Vector2(0, 1) # Down
var base_speed = 50
var speed_increment = 1

func init(new_position, new_direction, new_speed_increment = null, _new_color = null):
	if new_position:
		self.position = new_position
	if new_direction:
		self.direction = new_direction
	if new_speed_increment:
		self.speed_increment = new_speed_increment
#	pass # Replace with function body.

func _physics_process(delta):
	var speed = base_speed * speed_increment
	self.position += direction * speed * delta

func _on_Bullet_area_entered(area):
	emit_signal("hit", area, self.position)
	queue_free()
