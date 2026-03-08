extends Node
# EnemyAI.gd — Pathfinding + behavior states

enum State { IDLE, PATROL, CHASE, ATTACK, STUNNED }

@export var detection_range: float = 300.0
@export var attack_range: float = 150.0
@export var patrol_distance: float = 150.0
@export var patrol_speed: float = 60.0

var state: State = State.PATROL
var patrol_origin: Vector2
var patrol_dir: float = 1.0
var patrol_timer: float = 0.0
var attack_cooldown: float = 0.0
var stun_timer: float = 0.0

var enemy: CharacterBody2D  # Reference to the enemy node
var player: Node

func _ready():
	enemy = get_parent()
	patrol_origin = enemy.global_position
	player = get_tree().get_first_node_in_group("player")

func process(delta: float):
	if not player or enemy.is_dead:
		return
	attack_cooldown = max(0, attack_cooldown - delta)
	match state:
		State.IDLE: _state_idle(delta)
		State.PATROL: _state_patrol(delta)
		State.CHASE: _state_chase(delta)
		State.ATTACK: _state_attack(delta)
		State.STUNNED: _state_stunned(delta)

func _state_idle(delta: float):
	enemy.velocity.x = 0
	patrol_timer += delta
	if patrol_timer > 1.5:
		patrol_timer = 0
		state = State.PATROL
	_check_player_detection()

func _state_patrol(delta: float):
	var target_x = patrol_origin.x + patrol_dir * patrol_distance
	var dist_to_target = abs(enemy.global_position.x - target_x)
	if dist_to_target < 5:
		patrol_dir *= -1
		state = State.IDLE
	else:
		enemy.velocity.x = patrol_dir * patrol_speed
		if enemy.sprite:
			enemy.sprite.flip_h = patrol_dir < 0
	_check_player_detection()

func _check_player_detection():
	var dist = enemy.global_position.distance_to(player.global_position)
	if dist <= detection_range:
		state = State.CHASE

func _state_chase(delta: float):
	var dist = enemy.global_position.distance_to(player.global_position)
	if dist > detection_range * 1.5:
		state = State.PATROL
		return
	if dist <= attack_range:
		state = State.ATTACK
		enemy.velocity.x = 0
		return
	# Move toward player
	var dir = sign(player.global_position.x - enemy.global_position.x)
	enemy.velocity.x = dir * enemy.move_speed
	if enemy.sprite:
		enemy.sprite.flip_h = dir < 0

func _state_attack(_delta: float):
	enemy.velocity.x = 0
	var dist = enemy.global_position.distance_to(player.global_position)
	if dist > attack_range * 1.2:
		state = State.CHASE
		return
	if attack_cooldown <= 0:
		_perform_attack()
		attack_cooldown = get_attack_cooldown()

func _perform_attack():
	pass  # Override in specific enemy scripts

func get_attack_cooldown() -> float:
	return 1.5  # Override per enemy type

func _state_stunned(delta: float):
	stun_timer -= delta
	enemy.velocity.x *= 0.8
	if stun_timer <= 0:
		state = State.CHASE

func stun(duration: float):
	state = State.STUNNED
	stun_timer = duration
