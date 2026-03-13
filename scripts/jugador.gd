extends CharacterBody2D

const VELOCIDAD = 250.0
const VELOCIDAD_SALTO = -550.0
const GRAVEDAD = 980.0
const VIDA_MAX = 100

@onready var sprite = $AnimatedSprite2D
@onready var sonido_disparo = $gun_shot1
@onready var jump_sound = $jump_sound
@onready var hud = get_node("/root/Level1_1/HUD")  # ← nuevo

var vida = VIDA_MAX
var esta_muerto = false
var esta_disparando = false

func _physics_process(delta):
	if esta_muerto:
		return
	if not is_on_floor():
		velocity.y += GRAVEDAD * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = VELOCIDAD_SALTO
		jump_sound.play()
	if Input.is_action_just_pressed("shoot"):
		esta_disparando = true
		sprite.play("shoot")
		sonido_disparo.play()
		_disparar()
		await sprite.animation_finished
		esta_disparando = false
	var direccion = Input.get_axis("move_left", "move_right")
	velocity.x = direccion * VELOCIDAD
	if direccion < 0:
		sprite.flip_h = true
	elif direccion > 0:
		sprite.flip_h = false
	move_and_slide()
	if not esta_disparando and not esta_muerto:
		if not is_on_floor():
			sprite.play("Jump")
		elif direccion != 0:
			sprite.play("Run")
		else:
			sprite.play("Static")

const Bala = preload("res://scenes/player/Bala.tscn")

func _disparar():
	var bala = Bala.instantiate()
	var dir = -1 if sprite.flip_h else 1
	bala.dir = dir
	bala.global_position = global_position + Vector2(30 * dir, -15)
	get_parent().add_child(bala)

func recibir_dano(dano):
	if esta_muerto:
		return
	vida -= dano
	hud.actualizar_vida(vida)  
	if vida <= 0:
		morir()

func morir():
	if esta_muerto:
		return
	esta_muerto = true
	velocity = Vector2.ZERO
	esta_disparando = false
	sprite.play("die")
	await get_tree().create_timer(1.0).timeout
	SceneManager.go_to_game_over()
	
