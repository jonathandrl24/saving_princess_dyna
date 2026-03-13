extends Control

func _ready():
	# Connect buttons to functions
	$VBoxContainer/PLAYButton.pressed.connect(_on_play)
	$VBoxContainer/QUITButton.pressed.connect(_on_quit)

func _on_play():
	SceneManager.start_game()

func _on_quit():
	get_tree().quit()
