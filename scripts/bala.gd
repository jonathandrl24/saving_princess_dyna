extends Area2D

var dir = 1
const VELOCIDAD = 600.0

func _physics_process(delta):
	position.x += VELOCIDAD * dir * delta
	if position.x > 2000 or position.x < -500:
		queue_free()

func _on_body_entered(body):
	if body.has_method("recibir_dano"):
		body.recibir_dano(20)
	queue_free()
