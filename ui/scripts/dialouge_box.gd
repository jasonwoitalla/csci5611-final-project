extends Control


@onready var text : RichTextLabel = $TextureRect/RichTextLabel

func set_dialogue(dialogue : String) -> void:
	text.text = dialogue
	text.visible_ratio = 0
	var tween : Tween = create_tween()
	tween.tween_property(text, "visible_ratio", 1, 8.0)


func _on_button_pressed():
	visible = false
	GameManager.change_state(GameManager.State.PLAY)
