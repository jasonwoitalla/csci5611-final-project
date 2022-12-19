extends CharacterBody3D


@export var speed : float = 6.0
@export var seperation : float = 1.0
@export var attraction : float = 1.0
@export var alignment : float = 1.0

@onready var player : Node3D = get_node("/root/Zoo/Player")
@onready var cooldown : Timer = $Cooldown

const RUN_VELOCITY : float = 1.0
var actual_speed : float = 0.0
var goal_radius : float = 7.5
var goal_pos : Vector3 = Vector3.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var acceleration : Vector3 = Vector3.ZERO


func _ready():
	get_new_goal()


func _physics_process(delta : float) -> void:
	actual_speed = Vector3(velocity.x, 0, velocity.z).length()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	var acceleration : Vector3 = Vector3.ZERO
	# acceleration += vec2ToVec3(attraction_rule())
	# acceleration += vec2ToVec3(alignment_rule())
	acceleration += vec2ToVec3(seperation_rule())
	
	# Goal force
	if position.distance_to(goal_pos) < 0.5 and cooldown.is_stopped(): # get a new goal
		cooldown.start()
	else:
		acceleration += (goal_pos - position) / 80
	
	velocity += acceleration
	velocity = velocity.limit_length(speed)
	rotation.y = lerp_angle(rotation.y, atan2(velocity.x, velocity.z), 0.15)
	
	move_and_slide()


func attraction_rule() -> Vector2:
	# center of mass
	var com : Vector2 = Vector2.ZERO
	var count : int = 0
	var position2 : Vector2 = Vector2(position.x, position.z)
	
	for child in get_parent().get_children():
		if child != self: # don't include self in center of mass
			var child_pos : Vector2 = Vector2(child.position.x, child.position.z)
			if child_pos.distance_to(position2) <= 10:
				com += child_pos
				count += 1
	
	com /= count
	return (com - position2) / (attraction * 100)


func alignment_rule() -> Vector2:
	var cov : Vector2 = Vector2.ZERO
	var count : int = 0
	var position2 : Vector2 = Vector2(position.x, position.z)
	
	for child in get_parent().get_children():
		if child != self:
			var child_pos : Vector2 = Vector2(child.position.x, child.position.z)
			if child_pos.distance_to(position2) <= 10:
				cov += Vector2(child.velocity.x, child.velocity.z)
				count += 1
			
	cov /= (get_parent().get_child_count() - 1)
	return (cov - Vector2(velocity.x, velocity.z)) / (alignment * 8)


func seperation_rule() -> Vector2:
	var c : Vector2 = Vector2.ZERO
	var position2 : Vector2 = Vector2(position.x, position.z)
	
	for child in get_parent().get_children():
		if child != self:
			var childPos : Vector2 = Vector2(child.position.x, child.position.z)
			if childPos.distance_to(position2) < 3:
				c -= (childPos - position2) * seperation
	
	if player: 
		var global_pos2 : Vector2 = Vector2(global_position.x, global_position.z)
		var global_player : Vector2 = Vector2(player.global_position.x, player.global_position.z)
		if global_player.distance_to(global_pos2) < 3:
			c -= (global_player - global_pos2) * seperation
	
	return c
	
func vec2ToVec3(vector : Vector2) -> Vector3:
	return Vector3(vector.x, 0, vector.y)
	

func get_new_goal() -> void:
	goal_pos = Vector3(randf_range(-goal_radius, goal_radius), 0, randf_range(-goal_radius, goal_radius))


func _on_cooldown_timeout():
	get_new_goal()
