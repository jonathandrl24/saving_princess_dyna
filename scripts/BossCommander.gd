extends "res://scripts/Boss.gd"
# BossCommander — Energy shield, phase summons

@export var bullet_scene: PackedScene
@export var soldier_scene: PackedScene
@export var shield_node: Node2D

var _shield_active: bool = true
var _attack_timer: float = 0.0
var _max_summons: int = 3

func _boss_ready():
	max_health = 250
	score_value = 800
	if shield_node:
		shield_node.visible = true

func _boss_process(delta: float):
	if not player_ref:
		return
	_face_player()
	_attack_timer -= delta
	if _attack_timer <= 0:
		_choose_attack()
		_attack_timer = _get_attack_interval()

func _get_attack_interval() -> float:
	match current_phase:
		1: return 2.0
		2: return 1.5
		3: return 1.0
	return 2.0

func _choose_attack():
	match current_phase:
		1:
			if _shield_active:
				_shoot_burst(3)
			else:
				_shoot_burst(4)
		2:
			_shoot_burst(5)
			if randi() % 2 == 0:
				_summon_soldier()
		3:
			_shoot_spread(8)
			_summon_soldier()

func _shoot_burst(count: int):
	if not bullet_scene or not player_ref:
		return
	for i in count:
		await get_tree().create_timer(0.1 * i).timeout
		if is_dead:
			return
		var bullet = bullet_scene.instantiate()
		get_tree().root.add_child(bullet)
		bullet.global_position = global_position + Vector2(0, -20)
		bullet.direction = (player_ref.global_position - bullet.global_position).normalized()
		bullet.damage = 15

func _shoot_spread(count: int):
	if not bullet_scene:
		return
	for i in count:
		var bullet = bullet_scene.instantiate()
		get_tree().root.add_child(bullet)
		bullet.global_position = global_position + Vector2(0, -20)
		var angle = lerp(-0.8, 0.8, float(i) / float(count - 1))
		var base_dir = Vector2(-1 if sprite.flip_h else 1, -0.2).normalized()
		bullet.direction = base_dir.rotated(angle)
		bullet.damage = 12

func _summon_soldier():
	if not soldier_scene:
		return
	for i in _max_summons:
		var s = soldier_scene.instantiate()
		get_tree().root.add_child(s)
		s.global_position = global_position + Vector2(randf_range(-100, 100), -50)

func _on_phase_enter(phase: int):
	match phase:
		2:
			# Shield breaks at phase 2
			_shield_active = false
			if shield_node:
				shield_node.visible = false
			AudioManager.play_sfx("boss_roar")
		3:
			_max_summons = 2

func _face_player():
	if player_ref:
		sprite.flip_h = player_ref.global_position.x < global_position.x

func _on_boss_die():
	if shield_node:
		shield_node.visible = false
