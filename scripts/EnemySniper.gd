extends "res://scripts/Enemy.gd"
# EnemySniper — Stays static, fires slow precise laser

@export var laser_scene: PackedScene
@export var fire_rate: float = 3.0
@export var detection_range: float = 500.0

@onready var shoot_point: Marker2D = $ShootPoint
@onready var laser_sight: Line2D = $LaserSight
@onready var fire_timer: Timer = $FireTimer
@onready var aim_timer: Timer = $AimTimer

var _aiming: bool = false

func _on_ready_extra():
	max_health = 20
	move_speed = 0.0
	score_value = 150
	damage_on_contact = 5
	fire_timer.wait_time = fire_rate
	fire_timer.timeout.connect(_fire_laser)
	aim_timer.wait_time = 1.2
	aim_timer.timeout.connect(_release_shot)
	if laser_sight:
		laser_sight.visible = false

func _ai_process(_delta: float):
	if not player_ref:
		return
	_face_player()
	var dist = global_position.distance_to(player_ref.global_position)
	if dist <= detection_range:
		if fire_timer.is_stopped():
			fire_timer.start()
		_update_laser_sight()
	else:
		fire_timer.stop()
		if laser_sight:
			laser_sight.visible = false

func _update_laser_sight():
	if not laser_sight or not shoot_point:
		return
	laser_sight.visible = _aiming
	if _aiming:
		var dir = (player_ref.global_position - shoot_point.global_position).normalized()
		laser_sight.set_point_position(0, Vector2.ZERO)
		laser_sight.set_point_position(1, dir * 600)

func _fire_laser():
	if is_dead:
		return
	_aiming = true
	if laser_sight: laser_sight.visible = true
	aim_timer.start()

func _release_shot():
	_aiming = false
	if laser_sight: laser_sight.visible = false
	if not laser_scene or not player_ref:
		return
	var laser = laser_scene.instantiate()
	get_tree().root.add_child(laser)
	laser.global_position = shoot_point.global_position if shoot_point else global_position
	laser.direction = (player_ref.global_position - laser.global_position).normalized()
	laser.damage = 20
	laser.speed = 350.0

func _on_die():
	fire_timer.stop()
	aim_timer.stop()
	if laser_sight: laser_sight.visible = false
