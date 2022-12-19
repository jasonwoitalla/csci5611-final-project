extends CharacterBody3D
class_name TTC


@export var speed : float = 4.0
@export var radius : float = 2.0
@export var agent_paths : Array[NodePath]
@export var start_path : NodePath
@export var end_path : NodePath
@export var k_avoid : float = 20.0
@export var k_goal : float = 1.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var actual_speed : float = 0.0
var RUN_VELOCITY : float = 0.5
var agents : Array[TTC]
var start_node : Node3D
var end_node : Node3D
var back_to_start = false


func _ready():
	back_to_start = false
	start_node = get_node(start_path)
	end_node = get_node(end_path)
	for path in agent_paths:
		agents.append(get_node(path))


func _physics_process(delta):
	actual_speed = Vector3(velocity.x, 0, velocity.z).length()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	if global_position.distance_to(get_goal().global_position) < 1.0:
		back_to_start = !back_to_start

	var acc : Vector2 = computeForces()
	velocity.x += acc.x
	velocity.z += acc.y

	move_and_slide()
	
	
func computeForces() -> Vector2:
	var acc : Vector3 = Vector3.ZERO
	
	var goal_vel : Vector3 = get_goal().global_position - global_position
	goal_vel = goal_vel.limit_length(speed)
	rotation.y = lerp_angle(rotation.y, atan2(goal_vel.x, goal_vel.z), 0.15)
	
	if goal_vel.length() > (speed*0.1):
		for agent in agents:
			if agent == self:
				continue
			var ttc : float = computeTTC(agent)
			
			if ttc <= 0: # there is no collision
				continue
			
			var a_future : Vector3 = global_position + (velocity*ttc)
			var b_future : Vector3 = agent.global_position + (agent.velocity*ttc)
			var relative_future_dir : Vector3 = b_future.direction_to(a_future)
			var force_factor : float = k_avoid * (1/ttc)
			
			acc += relative_future_dir * force_factor
	
	var goal_force : Vector3 = Vector3.ZERO
	goal_force = goal_vel - velocity
	goal_force *= k_goal
	
	acc += goal_force
	
	return Vector2(acc.x, acc.z)
	
	
func computeTTC(other : TTC) -> float:
	var radAB : float = radius + other.radius
	var dir : Vector3 = other.velocity - velocity
	var ttc = rayCircleIntersectTime(global_position, radAB, other.global_position, dir)
	return ttc
	

func rayCircleIntersectTime(center : Vector3, r : float, start : Vector3, dir : Vector3) -> float:
	var to_circle : Vector3 = center - start
	var a : float = dir.length_squared()
	var b : float = -2 * to_circle.dot(dir)
	var c : float = to_circle.length_squared() - (r * r)
	
	var d : float = b * b - 4 * a * c
	if d >= 0:
		var t : float = (-b - sqrt(d)) / (2 * a)
		if t >= 0:
			return t
		return -1.0
	
	return -1.0
	

func get_goal() -> Node3D:
	if back_to_start:
		return start_node
	return end_node
