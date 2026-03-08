extends "res://scripts/Enemy.gd"
# EnemySoldier behavior — basic, approaches and shoots

@export var bullet_scene: PackedScene
@export var fire_rate: float = 1.5
@export var detection_range: float = 300.0
@export var attack_range: float = 160.0

@onready var ai: Node = $EnemyAI
@onready var shoot_point: Marker2D = $ShootPoint
@onready var fire_timer: Timer = $FireTimer

var _chasing: bool = false

func _on_ready_extra():
	if fire_timer:
		fire_timer.wait_time = fire_rate
		fire_timer.timeout.connect(_shoot)

func _ai_process(delta: float):
	if not player_ref:
		return
	_face_player()
	var dist = global_position.distance_to(player_ref.global_position)
	if dist > detection_range:
		# Patrol
		velocity.x = 0
		if sprite: sprite.play("idle")
		return
	if dist > attack_range:
		# Chase
		_chasing = true
		var dir = sign(player_ref.global_position.x - global_position.x)
		velocity.x = dir * move_speed
		if sprite: sprite.play("run")
		if fire_timer.is_stopped():
			fire_timer.start()
	else:
		# Attack position — stop and shoot
		velocity.x = 0
		if sprite: sprite.play("shoot")
		if fire_timer.is_stopped():
			fire_timer.start()

func _shoot():
	if is_dead or not player_ref or not bullet_scene:
		return
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	var sp = shoot_point if shoot_point else self
	bullet.global_position = sp.global_position
	var dir = (player_ref.global_position - sp.global_position).normalized()
	bullet.direction = dir
	bullet.damage = 10

func _on_die():
	if fire_timer:
		fire_timer.stop()
