extends Node
# SceneManager.gd — Autoload: scene transitions

signal scene_loaded(scene_name: String)

var _current_scene: Node = null
var _loading: bool = false

func _ready():
	var root = get_tree().root
	_current_scene = root.get_child(root.get_child_count() - 1)

func goto_scene(path: String):
	if _loading:
		return
	_loading = true
	# Fade out then switch
	var tween = get_tree().create_tween()
	# If there's a CanvasLayer with a ColorRect for fade, animate it
	# Otherwise just switch directly
	_do_switch.call_deferred(path)

func _do_switch(path: String):
	get_tree().change_scene_to_file(path)
	_loading = false

func goto_main_menu():
	goto_scene("res://scenes/ui/MainMenu.tscn")

func goto_game_over():
	goto_scene("res://scenes/ui/GameOver.tscn")

func start_game():
	GameManager.reset_game()
	goto_scene("res://scenes/ui/DialogueIntro.tscn")

func start_first_level():
	goto_scene("res://scenes/levels/world1/Level1_1.tscn")
