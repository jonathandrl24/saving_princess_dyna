extends "res://scripts/Boss.gd"
# BossVorzakKing — Final boss, 3 phases, Dyna chained behind

@export var bullet_scene: PackedScene
@export var missile_scene: PackedScene
@export var shockwave_scene: PackedScene
@export var princess_dyna: Node2D  # Reference to Dyna node (chained)

var _attack_timer: float = 0.0
var _move_target: float = 0.0
var _base_x: float = 0.0
var _enraged: bool = false

func _boss_ready():
	max_health = 500
	score_value = 5000
	phase_health_thresholds = [0.66, 0.33]
	_base_x = global_position.x
	_move_target = _base_x
	AudioManager.play_music("final_boss")
	AudioManager.play_sfx("boss_roar")

func _boss_process(delta: float):
	if not player_ref:
		return
	_face_player()
	# Hover movement
	var target_vel = (_move_target - global_position.x) * 3.0
	velocity.x = lerp(velocity.x, target_vel, 0.1)

	_attack_timer -= delta
	if _attack_timer <= 0:
		_execute_attack()
		_attack_timer = _get_interval()

func _get_interval() -> float:
	match current_phase:
		1: return 2.2
		2: return 1.6
		3: return 1.0
	return 2.0

func _execute_attack():
	match current_phase:
		1: _phase1_attack()
		2: _phase2_attack()
		3: _phase3_attack()

func _phase1_attack():
	var r = randi() % 2
	if r == 0:
		_shoot_triple()
	else:
		_ground_slam()

func _phase2_attack():
	var r = randi() % 3
	if r == 0:
		_shoot_triple()
	elif r == 1:
		_fire_missiles()
	else:
		_ground_slam()

func _phase3_attack():
	_shoot_triple()
	await get_tree().create_timer(0.3).timeout
	_fire_missiles()
	_enraged = true

func _shoot_triple():
	if not bullet_scene or not player_ref:
		return
	for offset in [-0.3, 0.0, 0.3]:
		var bullet = bullet_scene.instantiate()
		get_tree().root.add_child(bullet)
		bullet.global_position = global_position + Vector2(0, -30)
		var dir = (player_ref.global_position - bullet.global_position).normalized().rotated(offset)
		bullet.direction = dir
		bullet.damage = 20
		bullet.speed = 350.0

func _fire_missiles():
	if not missile_scene or not player_ref:
		return
	for i in 3:
		await get_tree().create_timer(0.4 * i).timeout
		if is_dead:
			return
		var missile = missile_scene.instantiate()
		get_tree().root.add_child(missile)
		missile.global_position = global_position + Vector2(randf_range(-80, 80), -50)
		missile.target = player_ref

func _ground_slam():
	# Jump and slam — causes shockwave
	velocity.y = -500
	await get_tree().create_timer(0.6).timeout
	if is_dead:
		return
	if shockwave_scene:
		var sw = shockwave_scene.instantiate()
		get_tree().root.add_child(sw)
		sw.global_position = global_position
	# Camera shake
	if player_ref:
		var cam = player_ref.get_node_or_null("Camera2D")
		if cam:
			var tween = create_tween()
			for i in 8:
				tween.tween_property(cam, "offset",
					Vector2(randf_range(-15, 15), randf_range(-15, 15)), 0.05)
			tween.tween_property(cam, "offset", Vector2.ZERO, 0.05)

func _on_phase_enter(phase: int):
	AudioManager.play_sfx("boss_roar")
	match phase:
		2:
			# Enrage visually
			sprite.modulate = Color(1.3, 0.8, 0.8)
			_move_target = _base_x + randf_range(-150, 150)
		3:
			sprite.modulate = Color(1.6, 0.5, 0.5)
			_move_target = _base_x

func _face_player():
	if player_ref:
		sprite.flip_h = player_ref.global_position.x < global_position.x

func _on_boss_die():
	# Release Dyna
	if princess_dyna:
		princess_dyna.play_free_animation()
	# Trigger outro dialogue
	await get_tree().create_timer(3.0).timeout
	SceneManager.goto_scene("res://scenes/ui/DialogueOutro.tscn")
