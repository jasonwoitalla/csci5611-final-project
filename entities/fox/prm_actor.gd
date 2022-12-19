extends CharacterBody3D


@export var prm_path : NodePath
@export var speed : float = 6.0

var prm : PRM
var actual_speed : float = 0.0
var RUN_VELOCITY : float = 0.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var path : Array[Vector3]
var index : int = 0
var picking_path : bool = false


func _ready():
	prm = get_node(prm_path)
	path = prm.get_random_path()
	global_position = path[0] # starting point
	global_position.y = 8


func _physics_process(delta):
	actual_speed = Vector3(velocity.x, 0, velocity.z).length()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# navigate to next node
	var global_xz : Vector2 = Vector2(global_position.x, global_position.z)
	var path_xz : Vector2 = Vector2(path[index].x, path[index].z)
	if global_xz.distance_to(path_xz) > 0.5:
		var dir : Vector3 = global_position.direction_to(path[index])
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
		rotation.y = lerp_angle(rotation.y, atan2(velocity.x, velocity.z), 0.15)
	else:
		if index < path.size() - 1:
			# print("next node")
			index += 1
		else:
			velocity = Vector3.ZERO
			if not picking_path:
				new_path()
	
	move_and_slide()


func new_path() -> void:
	picking_path = true
	# print("Arrived at dest, going to pick a new path now")
	await get_tree().create_timer(3.0).timeout
	path = prm.get_random_path(0)
	index = 0
	picking_path = false
