extends CharacterBody2D

const GRAVEDAD = 980.0
const DISTANCIA_RESCATE = 100.0

@onready var sprite = $AnimatedSprite2D

var jugador = null
var rescatada = false

func _ready():
	sprite.play("idle")
	jugador = get_node("/root/Level1_1/Player/jugador")

func _physics_process(delta):
	if rescatada:
		return

	if not is_on_floor():
		velocity.y += GRAVEDAD * delta

	if jugador != null:
		var distancia = global_position.distance_to(jugador.global_position)
		if distancia <= DISTANCIA_RESCATE:
			_rescatar()

	move_and_slide()

func _rescatar():
	rescatada = true
	sprite.play("idle")  # play a happy animation here if you have one
	await get_tree().create_timer(1.0).timeout
	SceneManager.go_to_mission_complete()
