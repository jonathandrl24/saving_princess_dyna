extends Node
# SceneManager.gd
# One job: change scenes cleanly.
# We call SceneManager.go_to("res://path/to/scene.tscn") from anywhere.

func go_to(path: String):
	get_tree().change_scene_to_file(path)

func start_game():
	GameManager.reset_game()
	go_to("res://scenes/levels/world1/Level1_1.tscn")

func go_to_main_menu():
	go_to("res://scenes/ui/MainMenu.tscn")

func go_to_game_over():
	go_to("res://scenes/ui/game_over.tscn")

func go_to_mission_complete():
	go_to("res://scenes/ui/mission_complete.tscn")
