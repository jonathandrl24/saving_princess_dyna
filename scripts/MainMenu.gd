extends Control
# MainMenu.gd

@onready var play_button: Button = $CenterContainer/VBox/PlayButton
@onready var options_button: Button = $CenterContainer/VBox/OptionsButton
@onready var quit_button: Button = $CenterContainer/VBox/QuitButton
@onready var title_label: Label = $CenterContainer/VBox/TitleLabel

func _ready():
	play_button.pressed.connect(_on_play)
	options_button.pressed.connect(_on_options)
	quit_button.pressed.connect(_on_quit)
	AudioManager.play_music("menu")
	# Animate title
	title_label.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(title_label, "modulate:a", 1.0, 1.2)

func _on_play():
	AudioManager.play_sfx("pickup")
	SceneManager.start_game()

func _on_options():
	SceneManager.goto_scene("res://scenes/ui/OptionsMenu.tscn")

func _on_quit():
	get_tree().quit()

func _input(event: InputEvent):
	if event.is_action_pressed("pause"):
		_on_quit()
