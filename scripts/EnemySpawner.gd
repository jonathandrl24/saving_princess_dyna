extends Node2D
# EnemySpawner.gd — Spawns enemies at intervals

@export var enemy_scene: PackedScene
@export var spawn_count: int = 3
@export var spawn_interval: float = 5.0
@export var max_alive: int = 3
@export var active: bool = true
@export var trigger_range: float = 400.0

@onready var timer: Timer = $Timer

var _spawned: Array = []
var _total_spawned: int = 0
var player_ref: Node = null

func _ready():
	player_ref = get_tree().get_first_node_in_group("player")
	timer.wait_time = spawn_interval
	timer.timeout.connect(_try_spawn)
	if active:
		timer.start()

func _try_spawn():
	if not active or not enemy_scene:
		return
	if _total_spawned >= spawn_count:
		timer.stop()
		return
	# Clean dead references
	_spawned = _spawned.filter(func(e): return is_instance_valid(e))
	if _spawned.size() >= max_alive:
		return
	# Only spawn if player is nearby
	if player_ref:
		var dist = global_position.distance_to(player_ref.global_position)
		if dist > trigger_range:
			return
	var enemy = enemy_scene.instantiate()
	get_parent().add_child(enemy)
	enemy.global_position = global_position + Vector2(randf_range(-30, 30), 0)
	_spawned.append(enemy)
	_total_spawned += 1
