extends Control
# DialogueIntro.gd — Opening cinematic

@onready var avatar_label: Label = $Panel/HBox/Avatar
@onready var speaker_label: Label = $Panel/HBox/Content/SpeakerName
@onready var dialogue_label: Label = $Panel/HBox/Content/DialogueText
@onready var tag_label: Label = $Panel/HBox/Content/Tag
@onready var continue_hint: Label = $ContinueHint
@onready var skip_button: Button = $SkipButton

const LINES = [
	{
		"avatar": "🪖",
		"speaker": "IMPERIAL SOLDIER",
		"text": "Princess Dyna has been taken by the Vorzak.\nI don't care what it takes.\nHumanity First.",
		"tag": "// Year 2387 — Imperial Space — Briefing Room"
	}
]

var _current_line: int = 0
var _typing: bool = false
var _tween: Tween

func _ready():
	AudioManager.play_music("menu")
	skip_button.pressed.connect(_skip)
	_show_line(0)

func _show_line(index: int):
	if index >= LINES.size():
		_proceed()
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

func _skip():
	_proceed()

func _proceed():
	SceneManager.start_first_level()
