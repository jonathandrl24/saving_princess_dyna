extends Node
# GameManager.gd — Autoload: global state, lives, level

signal health_changed(current: int, max_val: int)
signal ammo_changed(current: int, is_spam: bool)
signal lives_changed(lives: int)
signal score_changed(score: int)
signal game_over
signal level_complete

# Player state
var player_health: int = 100
var player_health_max: int = 100
var player_ammo: int = 30
var player_ammo_max: int = 30
var player_lives: int = 3
var player_score: int = 0
var spam_mode_active: bool = false
var has_shield: bool = false

# Level state
var current_world: int = 1
var current_level: int = 1
var checkpoints_reached: Array = []

# Difficulty
var difficulty: float = 1.0  # 1.0 = normal, 1.5 = hard

const WORLD_SCENES = {
	1: {
		1: "res://scenes/levels/world1/Level1_1.tscn",
		2: "res://scenes/levels/world1/Level1_2.tscn",
		3: "res://scenes/levels/world1/Level1_3_Boss.tscn"
	},
	2: {
		1: "res://scenes/levels/world2/Level2_1.tscn",
		2: "res://scenes/levels/world2/Level2_2.tscn",
		3: "res://scenes/levels/world2/Level2_3_Boss.tscn"
	},
	3: {
		1: "res://scenes/levels/world3/Level3_1.tscn",
		2: "res://scenes/levels/world3/Level3_2.tscn",
		3: "res://scenes/levels/world3/Level3_3_Boss.tscn"
	}
}

func _ready():
	reset_game()

func reset_game():
	player_health = player_health_max
	player_ammo = player_ammo_max
	player_lives = 3
	player_score = 0
	spam_mode_active = false
	has_shield = false
	current_world = 1
	current_level = 1
	checkpoints_reached.clear()

func take_damage(amount: int):
	if has_shield:
		has_shield = false
		return
	player_health = max(0, player_health - amount)
	health_changed.emit(player_health, player_health_max)
	if player_health <= 0:
		lose_life()

func heal(amount: int):
	player_health = min(player_health_max, player_health + amount)
	health_changed.emit(player_health, player_health_max)

func add_ammo(amount: int):
	player_ammo = min(player_ammo_max, player_ammo + amount)
	ammo_changed.emit(player_ammo, spam_mode_active)

func use_ammo(amount: int = 1) -> bool:
	if spam_mode_active:
		return true
	if player_ammo >= amount:
		player_ammo -= amount
		ammo_changed.emit(player_ammo, spam_mode_active)
		return true
	return false

func activate_spam_mode():
	spam_mode_active = true
	ammo_changed.emit(player_ammo, true)

func deactivate_spam_mode():
	spam_mode_active = false
	ammo_changed.emit(player_ammo, false)

func activate_shield():
	has_shield = true

func add_score(points: int):
	player_score += points
	score_changed.emit(player_score)

func lose_life():
	player_lives -= 1
	lives_changed.emit(player_lives)
	if player_lives <= 0:
		game_over.emit()
	else:
		# Respawn — restore health
		player_health = player_health_max
		health_changed.emit(player_health, player_health_max)

func complete_level():
	level_complete.emit()
	advance_level()

func advance_level():
	current_level += 1
	if current_level > 3:
		current_level = 1
		current_world += 1
	if current_world > 3:
		# Final boss
		SceneManager.goto_scene("res://scenes/levels/BossFinalLevel.tscn")
	else:
		var path = WORLD_SCENES.get(current_world, {}).get(current_level, "")
		if path != "":
			SceneManager.goto_scene(path)
