extends CharacterBody3D


@export var speed : float = 5.0
@export var jump_speed : float = 10.0
@export var rotate_speed : float = 7.0


@onready var model : Node3D = $Model

var max_vertical_vel : float = 50.0
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var selected_angle : float = 0
var jumping : bool = false
var tween_done : bool = false
var off_ground : bool = false
var tween : Tween
var input : Vector3 = Vector3.ZERO
var rotate_target : Basis = Basis.IDENTITY
var max_dist : float = 0.0

# Motion Plan:
# 1. Pick a random angle to rotate to
# 2. Wait a second once rotated
# 3. Jump in the air
# 4. While not grounded, move forward at set speed
# 5. Once grounded, wait a second
# 6. Repeat


func _ready() -> void:
	max_dist = get_parent().get_meta("max_dist")
	
	# Create our motion plan tween
	tween = create_tween().set_loops()
	tween.tween_callback(pick_random_angle)
	tween.tween_interval(randf_range(1.7, 2.5))
	tween.tween_callback(jump_forward)
	
	tween.connect("loop_finished", loop_finished)
	

func _physics_process(delta : float) -> void:	
	# Movement
	if not is_on_floor():
		velocity.y -= gravity * delta
	velocity.y = clampf(velocity.y, -max_vertical_vel, max_vertical_vel)
	
	var direction : Vector3 = (basis * input).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0
		velocity.z = 0
	
	# Rotation
	if rotate_target:
		basis = basis.slerp(rotate_target, delta * rotate_speed)
	
	
	# Animation
	# if tween_done and not is_on_floor():
		# off_ground = true
	
	if tween_done and is_on_floor():
		tween_done = false
		off_ground = false
		velocity = Vector3.ZERO
		input = Vector3.ZERO
		await get_tree().create_timer(randf_range(0.7, 1.3), true, true, false).timeout
		tween.play()
	
	move_and_slide()


func pick_random_angle() -> void:
	if global_position.distance_to(get_parent().global_position) > max_dist:
		print("Too far from parent")
		var dir : Vector3 = (global_position - get_parent().global_position).normalized()
		var look_at : Basis = basis.looking_at(dir, Vector3(0, 1, 0))
		rotate_target = Basis.from_euler(Vector3(rotation.x, look_at.get_euler().y, rotation.z))
		return
	rotate_target = Basis.from_euler(Vector3(rotation.x, randf_range(0, 360), rotation.z))


func jump_forward() -> void:
	velocity.y = jump_speed
	jumping = true
	input = Vector3(0, 0, 1)
	
func loop_finished(loop_count : int) -> void:
	tween.pause()
	rotate_target = Basis.IDENTITY
	await get_tree().create_timer(0.2).timeout
	tween_done = true
	jumping = false


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Jump":
		print("Jumping is false")
		jumping = false


func _on_animation_player_animation_changed(old_name, new_name):
	print("Animation change")
	if new_name == "Jump_Idle":
		print("jumping is false")
		jumping = false
