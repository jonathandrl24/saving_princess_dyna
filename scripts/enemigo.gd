extends CharacterBody2D

const GRAVEDAD = 980.0
const VELOCIDAD = 80.0
const VIDA_MAX = 100
const DISTANCIA_ATAQUE = 80.0
const DANO_GOLPE = 20

@onready var sprite = $AnimatedSprite2D
@onready var punch_sound = $punch_sound

var vida = VIDA_MAX
var esta_muerto = false
var esta_atacando = false
var jugador = null
var tiempo_ataque = 0.0          # timer instead of await

func _ready():
	sprite.play("idle")
	jugador = get_node("/root/Level1_1/Player/jugador")

func _physics_process(delta):
	if esta_muerto:
		return

	if not is_on_floor():
		velocity.y += GRAVEDAD * delta

	# Cooldown timer counts down
	if tiempo_ataque > 0:
		tiempo_ataque -= delta
		move_and_slide()
		return                   # don't do anything else while on cooldown

	if jugador != null:
		var distancia = global_position.distance_to(jugador.global_position)
		if distancia <= DISTANCIA_ATAQUE:
			velocity.x = 0
			_golpear()
		elif distancia <= 400:
			var direccion = sign(jugador.global_position.x - global_position.x)
			velocity.x = direccion * VELOCIDAD
			sprite.flip_h = direccion < 0
			sprite.play("run")
		else:
			velocity.x = 0
			sprite.play("idle")

	move_and_slide()
	
func recibir_dano(dano = 20):  # ← default value so both bala and other calls work
	if esta_muerto:
		return
	vida -= dano
	print("Golem HP: ", vida, "%")
	sprite.play("hurt")
	if vida <= 0:
		morir()
		
func _golpear():
	sprite.play("attack_punch")
	punch_sound.play()
	# Deal damage immediately
	jugador.recibir_dano(DANO_GOLPE)
	print("Jugador golpeado! HP: ", jugador.vida, "%")
	# Block next attack for 1.5 seconds
	tiempo_ataque = 1.5

func morir():
	if esta_muerto:
		return
	esta_muerto = true
	velocity = Vector2.ZERO
	esta_atacando = false
	sprite.play("die")
	await get_tree().create_timer(2.0).timeout
	print("enemigo muerto")
