extends PathFollow2D

@export var speed = 150.0

func _process(delta):
	progress += speed * delta
