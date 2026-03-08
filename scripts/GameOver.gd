extends Control
# GameOver.gd

@onready var score_label: Label = $CenterContainer/VBox/ScoreLabel
@onready var retry_button: Button = $CenterContainer/VBox/RetryButton
@onready var menu_button: Button = $CenterContainer/VBox/MenuButton

func _ready():
	if score_label:
		score_label.text = "FINAL SCORE: %d" % GameManager.player_score
	retry_button.pressed.connect(_on_retry)
	menu_button.pressed.connect(_on_menu)

func _on_retry():
	SceneManager.start_game()

func _on_menu():
	SceneManager.goto_main_menu()
