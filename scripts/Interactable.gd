extends Node
class_name Interactable


@export var dialouge : String = "Hello World"

@onready var dialogue_box : Control = $DialougeBox
@onready var cam_target : Node3D = $CamTarget

func interact() -> void:
	print("Someone is interacting")
	dialogue_box.set_dialogue(dialouge)
	dialogue_box.visible = true
	

func get_cam_target() -> Transform3D:
	return cam_target.global_transform
