extends Control


@onready var inspect_box : Control = $TextureRect
@onready var creature_name : RichTextLabel = $TextureRect/CreatureName
@onready var creature_description : RichTextLabel = $TextureRect/CreatureDescription
@onready var anim : AnimationPlayer = $AnimationPlayer

func _ready():
	inspect_box.visible = false
	

func inspect(inspection_data : Array[String]) -> void:
	creature_name.text = inspection_data[0]
	creature_description.text = inspection_data[1]
	inspect_box.visible = true
	anim.play("appear")
