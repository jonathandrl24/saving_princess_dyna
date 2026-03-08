extends Node
# WeaponSystem.gd — Ammo logic and Spam Mode

@export var bullet_scene: PackedScene
@export var bullet_spam_scene: PackedScene
@export var shoot_point: Marker2D

# Normal fire
const FIRE_COOLDOWN: float = 0.25
const SPAM_FIRE_COOLDOWN: float = 0.06
const SPAM_DURATION: float = 5.0
const SPAM_SPREAD: float = 0.25  # radians random spread

var _fire_cooldown_timer: float = 0.0
var _spam_timer: float = 0.0
var is_firing: bool = false
var _spam_active: bool = false

signal spam_mode_started
signal spam_mode_ended(time_left: float)

func _ready():
	GameManager.ammo_changed.connect(_on_ammo_changed)

func _on_ammo_changed(_ammo: int, is_spam: bool):
	_spam_active = is_spam
	if is_spam:
		_spam_timer = SPAM_DURATION
		spam_mode_started.emit()
		AudioManager.play_sfx("spam_mode")

func handle_input():
	var delta = get_process_delta_time()
	_fire_cooldown_timer = max(0.0, _fire_cooldown_timer - delta)

	if _spam_active:
		_spam_timer -= delta
		if _spam_timer <= 0:
			_spam_active = false
			GameManager.deactivate_spam_mode()
			spam_mode_ended.emit(0.0)
		else:
			# Auto-fire in spam mode
			if _fire_cooldown_timer <= 0:
				_fire(true)
				_fire_cooldown_timer = SPAM_FIRE_COOLDOWN
			is_firing = true
	else:
		if Input.is_action_pressed("shoot"):
			if GameManager.player_ammo > 0:
				if _fire_cooldown_timer <= 0:
					if GameManager.use_ammo(1):
						_fire(false)
						_fire_cooldown_timer = FIRE_COOLDOWN
				is_firing = _fire_cooldown_timer > 0
			else:
				is_firing = false
		else:
			is_firing = false

func _fire(is_spam: bool):
	if not shoot_point:
		return
	var scene = bullet_spam_scene if is_spam else bullet_scene
	if not scene:
		return
	var bullet = scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_position = shoot_point.global_position

	var player = get_parent()
	var dir = Vector2.RIGHT if player.facing_right else Vector2.LEFT
	if is_spam:
		dir = dir.rotated(randf_range(-SPAM_SPREAD, SPAM_SPREAD))
	bullet.direction = dir
	AudioManager.play_sfx("shoot")

func activate_spam_mode():
	GameManager.activate_spam_mode()

func get_spam_time_remaining() -> float:
	return _spam_timer
