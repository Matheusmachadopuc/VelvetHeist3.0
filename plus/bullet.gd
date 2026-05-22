extends Area2D

var speed = 10000.0

func _physics_process(delta):
	# "transform.x" representa a direção frente do obj
	# manda a bala pra frente, multiplicando pela velocidade.
	position += transform.x * speed * delta


func _on_body_entered(body):
	if body.is_in_group("enemy"):
		body.hit()
	queue_free()
