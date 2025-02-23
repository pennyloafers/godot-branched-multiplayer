extends AnimatableBody3D
class_name Obst


static func create() -> Obst:
	return preload("res://examples/obstacle.tscn").instantiate()

var time_acc:float = 0.0
func _physics_process(delta: float) -> void:
	time_acc += delta
	position.x = 2.0 * sin(time_acc*PI)
