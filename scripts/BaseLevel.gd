extends Node2D
# BaseLevel.gd — Common level logic: HUD, pause, level complete

@export var world_number: int = 1
@export var level_number: int = 1
@export var world_music_key: String = "world1"
@export var is_boss_level: bool = false

@onready var hud: CanvasLayer = $HUD
@onready var pause_menu: Control = $PauseMenu
@onready var player: CharacterBody2D = $Player

var _paused: bool = false

func _ready():
	GameManager.current_world = world_number
	GameManager.current_level = level_number
	AudioManager.play_music(world_music_key)
	if player:
		player.add_to_group("player")
	if hud and hud.has_method("_refresh_all"):
		hud._refresh_all()
	if pause_menu:
		pause_menu.visible = false
	GameManager.game_over.connect(_on_game_over)
	GameManager.level_complete.connect(_on_level_complete)

func _input(event: InputEvent):
	if event.is_action_just_pressed("pause"):
		_toggle_pause()

func _toggle_pause():
	_paused = !_paused
	get_tree().paused = _paused
	if pause_menu:
		pause_menu.visible = _paused

func _on_game_over():
	SceneManager.goto_game_over()

func _on_level_complete():
	pass  # GameManager.advance_level() handles scene switch
