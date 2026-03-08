extends Control
# DialogueOutro.gd — Ending cinematic

@onready var avatar_label: Label = $Panel/HBox/Avatar
@onready var speaker_label: Label = $Panel/HBox/Content/SpeakerName
@onready var dialogue_label: Label = $Panel/HBox/Content/DialogueText
@onready var tag_label: Label = $Panel/HBox/Content/Tag
@onready var credits_container: Control = $CreditsContainer

const LINES = [
	{
		"avatar": "🪖",
		"speaker": "IMPERIAL SOLDIER",
		"text": "It's over, Dyna. The Empire stands.\nLet's go home.",
		"tag": "// Throne of Vorzak King — Mission Complete"
	},
	{
		"avatar": "👸",
		"speaker": "PRINCESS DYNA",
		"text": "I knew you'd come. You always do.\n★ Humanity First. Always. ★",
		"tag": "// The Empire is safe — for now"
	}
]

var _current_line: int = 0
var _typing: bool = false
var _tween: Tween

func _ready():
	AudioManager.play_music("menu")
	if credits_container:
		credits_container.visible = false
	_show_line(0)

func _show_line(index: int):
	if index >= LINES.size():
		_show_credits()
		return
	var line = LINES[index]
	if avatar_label: avatar_label.text = line["avatar"]
	if speaker_label: speaker_label.text = line["speaker"]
	if tag_label: tag_label.text = line["tag"]
	if dialogue_label:
		dialogue_label.text = ""
		_typing = true
		_tween = create_tween()
		var full_text = line["text"]
		_tween.tween_method(func(t: float):
			dialogue_label.text = full_text.substr(0, int(t * full_text.length())),
			0.0, 1.0, full_text.length() * 0.04)
		_tween.tween_callback(func(): _typing = false)

func _input(event: InputEvent):
	if event.is_action_just_pressed("shoot") or event.is_action_just_pressed("jump"):
		if _typing:
			if _tween: _tween.kill()
			_typing = false
			if dialogue_label and _current_line < LINES.size():
				dialogue_label.text = LINES[_current_line]["text"]
		else:
			_current_line += 1
			_show_line(_current_line)

func _show_credits():
	if credits_container:
		credits_container.visible = true
	await get_tree().create_timer(8.0).timeout
	SceneManager.goto_main_menu()
