extends "res://scripts/Enemy.gd"
# EnemyBerserker — Charges player, fires in all directions

@export var bullet_scene: PackedScene
@export var charge_speed: float = 200.0
@export var fire_rate: float = 0.4
@export var detection_range: float = 250.0
@export var num_bullets: int = 8  # Radial burst

@onready var fire_timer: Timer = $FireTimer

func _on_ready_extra():
	max_health = 50
	score_value = 200
	damage_on_contact = 15
	fire_timer.wait_time = fire_rate
	fire_timer.timeout.connect(_burst_fire)

func _ai_process(_delta: float):
	if not player_ref:
		return
	_face_player()
	var dist = global_position.distance_to(player_ref.global_position)
	if dist > detection_range:
		velocity.x = 0
		fire_timer.stop()
		if sprite: sprite.play("idle")
		return
	# Charge at player
	var dir = (player_ref.global_position - global_position).normalized()
	velocity.x = dir.x * charge_speed
	if sprite: sprite.play("run")
	if fire_timer.is_stopped():
		fire_timer.start()

func _burst_fire():
	if is_dead or not bullet_scene:
		return
	AudioManager.play_sfx("shoot")
	for i in num_bullets:
		var bullet = bullet_scene.instantiate()
		get_tree().root.add_child(bullet)
		bullet.global_position = global_position
		var angle = (TAU / num_bullets) * i
		bullet.direction = Vector2(cos(angle), sin(angle))
		bullet.damage = 8
		bullet.speed = 200.0

func _on_die():
	fire_timer.stop()
