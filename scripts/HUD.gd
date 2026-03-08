extends CanvasLayer
# HUD.gd — Health, ammo, lives, world display

@onready var health_bar: ProgressBar = $MarginContainer/VBox/TopRow/HealthBar
@onready var health_label: Label = $MarginContainer/VBox/TopRow/HealthLabel
@onready var ammo_label: Label = $MarginContainer/VBox/TopRow/AmmoLabel
@onready var lives_label: Label = $MarginContainer/VBox/TopRow/LivesLabel
@onready var score_label: Label = $MarginContainer/VBox/TopRow/ScoreLabel
@onready var world_label: Label = $MarginContainer/VBox/TopRow/WorldLabel
@onready var spam_bar: ProgressBar = $MarginContainer/VBox/SpamBar
@onready var spam_label: Label = $MarginContainer/VBox/SpamLabel
@onready var boss_health_container: Control = $BossHealthContainer
@onready var boss_health_bar: ProgressBar = $BossHealthContainer/BossHealthBar
@onready var boss_name_label: Label = $BossHealthContainer/BossNameLabel

func _ready():
	GameManager.health_changed.connect(_on_health_changed)
	GameManager.ammo_changed.connect(_on_ammo_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.score_changed.connect(_on_score_changed)
	_refresh_all()
	if boss_health_container:
		boss_health_container.visible = false
	if spam_bar:
		spam_bar.visible = false

func _refresh_all():
	_on_health_changed(GameManager.player_health, GameManager.player_health_max)
	_on_ammo_changed(GameManager.player_ammo, GameManager.spam_mode_active)
	_on_lives_changed(GameManager.player_lives)
	_on_score_changed(GameManager.player_score)
	if world_label:
		world_label.text = "WORLD %d" % GameManager.current_world

func _on_health_changed(current: int, max_val: int):
	if health_bar:
		health_bar.max_value = max_val
		health_bar.value = current
	if health_label:
		health_label.text = "%d / %d" % [current, max_val]
	# Color shift
	if health_bar:
		var ratio = float(current) / float(max_val)
		if ratio > 0.5:
			health_bar.modulate = Color.GREEN
		elif ratio > 0.25:
			health_bar.modulate = Color.YELLOW
		else:
			health_bar.modulate = Color.RED

func _on_ammo_changed(current: int, is_spam: bool):
	if ammo_label:
		if is_spam:
			ammo_label.text = "⚡ SPAM MODE ⚡"
			ammo_label.modulate = Color.YELLOW
		elif current <= 0:
			ammo_label.text = "NO AMMO — MELEE [F]"
			ammo_label.modulate = Color.RED
		else:
			ammo_label.text = "AMMO: %d" % current
			ammo_label.modulate = Color.CYAN
	if spam_bar:
		spam_bar.visible = is_spam

func _process(_delta: float):
	# Update spam timer bar
	if GameManager.spam_mode_active and spam_bar and spam_bar.visible:
		var ws = get_tree().get_first_node_in_group("player")
		if ws:
			var weapon = ws.get_node_or_null("WeaponSystem")
			if weapon:
				spam_bar.value = weapon.get_spam_time_remaining()

func _on_lives_changed(lives: int):
	if lives_label:
		lives_label.text = "♥ x%d" % lives

func _on_score_changed(score: int):
	if score_label:
		score_label.text = "SCORE: %d" % score

func show_boss_health(boss_name: String, current: int, max_val: int):
	if boss_health_container:
		boss_health_container.visible = true
	if boss_name_label:
		boss_name_label.text = "— " + boss_name + " —"
	if boss_health_bar:
		boss_health_bar.max_value = max_val
		boss_health_bar.value = current

func update_boss_health(current: int, max_val: int):
	if boss_health_bar:
		boss_health_bar.value = current

func hide_boss_health():
	if boss_health_container:
		boss_health_container.visible = false
