extends CharacterBody3D


@onready var path_follow : PathFollow3D = get_parent()


func _ready():
	var tween : Tween = create_tween().set_loops()
	tween.tween_property(path_follow, "progress_ratio", 1.0, 60.0)


func _physics_process(delta):
	

	move_and_slide()
