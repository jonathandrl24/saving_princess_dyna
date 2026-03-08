extends CharacterBody2D
# Player.gd — Movement, jump, shoot, damage

const SPEED: float = 250.0
const JUMP_VELOCITY: float = -550.0
const GRAVITY: float = 980.0
const COYOTE_TIME: float = 0.12
const JUMP_BUFFER_TIME: float = 0.1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon_system: Node = $WeaponSystem
@onready var shoot_point: Marker2D = $ShootPoint
@onready var melee_area: Area2D = $MeleeArea
@onready var hurtbox: Area2D = $Hurtbox
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var camera: Camera2D = $Camera2D

var facing_right: bool = true
var is_dead: bool = false
var is_invincible: bool = false
var _coyote_active: bool = false
var _jump_buffered: bool = false

signal player_died

func _ready():
	GameManager.health_changed.connect(_on_health_changed)
	hurtbox.area_entered.connect(_on_hurtbox_entered)
	invincibility_timer.timeout.connect(_on_invincibility_timeout)
	coyote_timer.timeout.connect(func(): _coyote_active = false)
	jump_buffer_timer.timeout.connect(func(): _jump_buffered = false)

func _physics_process(delta: float):
	if is_dead:
		return
	_apply_gravity(delta)
	_handle_movement()
	_handle_jump()
	_handle_shoot()
	_handle_melee()
	_update_animation()
	move_and_slide()
	_check_fell_off()

func _apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		if is_on_floor():  # Just landed — reset coyote
			_coyote_active = false
	else:
		velocity.y = 0
		_coyote_active = true
		coyote_timer.start(COYOTE_TIME)
		if _jump_buffered:
			_do_jump()
			_jump_buffered = false

func _handle_movement():
	var dir = Input.get_axis("move_left", "move_right")
	velocity.x = dir * SPEED
	if dir > 0:
		facing_right = true
		sprite.flip_h = false
	elif dir < 0:
		facing_right = false
		sprite.flip_h = true
	# Update shoot point
	shoot_point.position.x = abs(shoot_point.position.x) * (1 if facing_right else -1)
	melee_area.position.x = abs(melee_area.position.x) * (1 if facing_right else -1)

func _handle_jump():
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or _coyote_active:
			_do_jump()
		else:
			_jump_buffered = true
			jump_buffer_timer.start(JUMP_BUFFER_TIME)

func _do_jump():
	velocity.y = JUMP_VELOCITY
	_coyote_active = false
	AudioManager.play_sfx("jump")

func _handle_shoot():
	weapon_system.handle_input()

func _handle_melee():
	if Input.is_action_just_pressed("melee") and GameManager.player_ammo <= 0 and not GameManager.spam_mode_active:
		_do_melee()

func _do_melee():
	AudioManager.play_sfx("melee")
	sprite.play("melee")
	melee_area.monitoring = true
	await get_tree().create_timer(0.2).timeout
	melee_area.monitoring = false

func _update_animation():
	if is_dead:
		return
	if not is_on_floor():
		sprite.play("jump" if velocity.y < 0 else "fall")
	elif GameManager.spam_mode_active and weapon_system.is_firing:
		sprite.play("spam")
	elif weapon_system.is_firing:
		sprite.play("shoot")
	elif abs(velocity.x) > 10:
		sprite.play("run")
	else:
		sprite.play("idle")

func _check_fell_off():
	if global_position.y > 2000:
		take_damage(100)

func take_damage(amount: int):
	if is_invincible or is_dead:
		return
	GameManager.take_damage(amount)
	AudioManager.play_sfx("player_hit")
	_start_invincibility()
	_screen_shake()
	if GameManager.player_health <= 0:
		die()

func _on_health_changed(current: int, _max: int):
	if current <= 0:
		die()

func _start_invincibility():
	is_invincible = true
	invincibility_timer.start(1.5)
	# Blink effect
	var tween = create_tween().set_loops(6)
	tween.tween_property(sprite, "modulate:a", 0.2, 0.1)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.1)

func _on_invincibility_timeout():
	is_invincible = false
	sprite.modulate.a = 1.0

func _screen_shake():
	if camera:
		var tween = create_tween()
		for i in 5:
			tween.tween_property(camera, "offset",
				Vector2(randf_range(-8, 8), randf_range(-8, 8)), 0.04)
		tween.tween_property(camera, "offset", Vector2.ZERO, 0.04)

func _on_hurtbox_entered(area: Area2D):
	if area.is_in_group("enemy_bullets"):
		take_damage(area.damage)
	elif area.is_in_group("enemy_melee"):
		take_damage(area.damage)

func die():
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	AudioManager.play_sfx("death")
	sprite.play("die")
	player_died.emit()
	await get_tree().create_timer(2.0).timeout
	GameManager.lose_life()
	if GameManager.player_lives > 0:
		# Respawn at last checkpoint or level start
		get_tree().reload_current_scene()
	else:
		SceneManager.goto_game_over()
