extends Area3D
class_name Inspectable


@export var inspect_name : String = "Creature"
@export var inspect_description : String = "This is a creature that can't move around"

@onready var marker : Node3D = $Marker


func get_data() -> Array[String]:
	return [inspect_name, inspect_description]


func _on_area_entered(area):
	marker.visible = true


func _on_area_exited(area):
	marker.visible = false
