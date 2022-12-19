extends CharacterBody3D


@export var speed : float = 5.0
@export var jump_speed : float = 4.5
@export var rotate_speed : float = 7.0
@export var max_vertical_vel : float = 50
@export var player_weight : float = 7.0
@export var camera : NodePath

@onready var model : Node3D = $Model
@onready var coyote_timer : Timer = $CoyoteTimer
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var interactor : ShapeCast3D = $Interactor

var get_input : bool = true
var can_jump : bool = true
var coyote : bool = false # keeps track of if the coyote timer is going off
var actual_speed : float = 0.0
var RUN_VELOCITY : float = 0.5
var jumping : bool = false
var inspectable : Array[Inspectable]

var camera_node : Node3D
var animation_node : AnimationPlayer
var npc : Interactable

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	camera_node = get_node(camera)
	animation_node = get_node(animation_tree.anim_player)


func _physics_process(delta):
	movement(delta)
	interaction(delta)
	
	
func movement(delta) -> void:
	actual_speed = Vector3(velocity.x, 0, velocity.z).length()
	
	# Model Rotation
	if camera_node and (velocity.x != 0 or velocity.z != 0): 
		rotation.y = camera_node.rotation.y
	
	# Get input vector
	var input_dir = Vector2.ZERO
	if get_input:
		input_dir = Input.get_vector("left", "right", "up", "down")
	
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif can_jump:
		velocity.y = -player_weight
	
	if is_on_ceiling():
		velocity.y = 0
		
	# Model Rotation
	var direction : Vector3 = (basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		var rotate_target : Basis = Basis.IDENTITY.looking_at(Vector3(direction.x, 0, direction.z))
		rotate_target = Basis.from_euler(Vector3(model.global_rotation.x, rotate_target.get_euler().y, model.global_rotation.z))
		model.global_transform.basis = model.global_transform.basis.slerp(rotate_target, delta * rotate_speed)
			
	
	# Speed
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0
		velocity.z = 0
	
	# Jumping logic
	if can_jump and not is_on_floor() and not coyote:
		coyote = true
		coyote_timer.start()
	if not can_jump and is_on_floor() and not Input.is_action_pressed("jump"):
		can_jump = true
	if Input.is_action_just_pressed("jump") and can_jump:
		jump()
		
	# Vertical velocity
	velocity.y = clampf(velocity.y, -max_vertical_vel, max_vertical_vel)
	
	move_and_slide()
	
	
func jump() -> void:
	can_jump = false
	velocity.y = jump_speed
	jumping = true
	

func interaction(delta : float) -> void:
	if interactor.collision_result.size() > 0:
		npc = interactor.collision_result[0].collider
	else:
		npc = null


func _input(event):
	if event.is_action_pressed("interact") and GameManager.state == GameManager.State.PLAY and npc:
		print("Trying to interact with an npc")
		GameManager.change_state(GameManager.State.INTERACT, npc.get_cam_target())
		npc.interact()
	elif event.is_action_pressed("interact") and inspectable.size() > 0:
		sort_inspectable()
		InspectLabel.inspect(inspectable[0].get_data())


func _on_coyote_timer_timeout():
	# Coyote time ran out, player can't jump anymore
	can_jump = false
	coyote = false


func _on_animation_tree_animation_player_changed():
	if animation_node == null:
		return
	if animation_node.current_animation == "Jump_Idle":
		jumping = false


func _on_inspector_area_entered(area):
	if not inspectable.has(area):
		inspectable.append(area)


func _on_inspector_area_exited(area):
	inspectable.erase(area)
	
	
func sort_inspectable() -> void:
	inspectable.sort_custom(func(a, b): return position.distance_to(a.position) < position.distance_to(b.position))
