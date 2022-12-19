extends Node3D
class_name PRM


@export var width : int = 50
@export var height : int = 50
@export var num_nodes : int = 50
@export var node_scene : PackedScene

@onready var node_parent : Node3D = $PRMNodes

var space : PhysicsDirectSpaceState3D
var nodes : Array[Node3D]
var neighbors : Array = []
var path : Array[int] = []
var last_end : int = -1


func _ready():
	space = get_world_3d().direct_space_state
	generate_random_nodes()
	connect_neighbors()


func generate_random_nodes() -> void:
	for i in num_nodes:
		var rand_pos : Vector2 = Vector2(randf_range(-width, width), randf_range(-height, height))
		while point_inside_obsticle(rand_pos):
			rand_pos = Vector2(randf_range(-width, width), randf_range(-height, height))
		var instance = node_scene.instantiate()
		instance.position = Vector3(rand_pos.x, 0, rand_pos.y)
		node_parent.add_child(instance)
		nodes.append(instance)
	
	
func connect_neighbors() -> void:
	for i in num_nodes:
		var neighbor : Array = []
		for j in num_nodes:
			if i == j:
				continue
			var dist : float = nodes[i].position.distance_to(nodes[j].position)
			if not(ray_interact(nodes[i].global_position, nodes[j].global_position)) and dist < 10:
				neighbor.append(j)
		neighbors.append(neighbor)
	
	
func point_inside_obsticle(point : Vector2) -> bool:
	var global_point = Vector3(point.x + global_position.x, global_position.y, point.y + global_position.z)
	var shape_rid = PhysicsServer3D.sphere_shape_create()
	PhysicsServer3D.shape_set_data(shape_rid, 0.25)
	
	var physics_shape : PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	physics_shape.shape_rid = shape_rid
	physics_shape.transform = Transform3D(Basis.IDENTITY, global_point)
	var res = space.intersect_shape(physics_shape)
	PhysicsServer3D.free_rid(shape_rid)
	return res.size() > 0
	

func ray_interact(from : Vector3, to : Vector3) -> bool:
	var physics_ray : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	var res = space.intersect_ray(physics_ray)
	return not (res == {})
	
	
func run_bfs(start : int, end : int) -> void:
	var fringe : Array[int] = []
	path = []
	
	var visited : Array[bool] = []
	visited.resize(num_nodes)
	visited.fill(false)
	
	var parent : Array[int] = []
	parent.resize(num_nodes)
	parent.fill(-1)
	
	# print("Beginning BFS")
	
	visited[start] = true
	fringe.append(start)
	
	while fringe.size() > 0:
		var cur_node : int = fringe[0]
		fringe.remove_at(0)
		if cur_node == end:
			# print("Goal found")
			break
		for i in neighbors[cur_node].size():
			var neighbor_node : int = neighbors[cur_node][i]
			if not visited[neighbor_node]:
				visited[neighbor_node] = true
				parent[neighbor_node] = cur_node
				fringe.append(neighbor_node)
	
	# Reconstruct path
	var prev_node : int = parent[end]
	path.insert(0, end)
	# printraw("Path: " + str(end) + " ")
	while prev_node >= 0:
		# printraw(str(prev_node) + " ")
		path.insert(0, prev_node)
		prev_node = parent[prev_node]
	# printraw("\n")
	

func get_random_path(start : int = -1) -> Array[Vector3]:
	var start_node = randi_range(0, num_nodes-1)
	var end_node = randi_range(0, num_nodes-1)
	while start_node == end_node:
		end_node = randi_range(0, num_nodes-1)
	if start >= 0:
		start_node = last_end
		
	run_bfs(start_node, end_node)
	var output : Array[Vector3]
	for i in path.size():
		output.append(nodes[path[i]].global_position)
	last_end = end_node
	
	return output
