extends Camera3D
class_name CameraOrbit

@export var target : NodePath
@export var zoom_target : NodePath
@export var distance : float = 15.0
@export var zoom_distance : float = 1.5
@export var x_speed : float = 250.0
@export var y_speed : float = 120.0
@export var y_min_limit : float = -40
@export var y_max_limit : float = 55

var mouse_delta : Vector2 = Vector2.ZERO
var stop_camera : bool = false
var x : float = 0.0
var y : float = 0.0
var zoom_speed : float = 20
var use_zoom_target : bool = false

var target_node : Node3D
var zoom_target_node : Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	x = rotation.y
	y = rotation.x
	
	target_node = get_node(target)
	zoom_target_node = get_node(zoom_target)
	print("Seeting our target: " + str(target))
	print("Our target location: " + str(get_target().position))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var quat : Quaternion = Quaternion.IDENTITY
	
	if not stop_camera:
		x -= mouse_delta.x * x_speed * delta
		y -= mouse_delta.y * y_speed * delta
		
		y = clamp_angle(y, y_min_limit, y_max_limit)
		
		distance += Input.get_axis("camera_zoom_in", "camera_zoom_out") * zoom_speed
		distance = clampf(distance, 1.5, 9.0)
		
		rotation = Vector3(deg_to_rad(y), deg_to_rad(x), 0)
		quat = Quaternion.from_euler(rotation)
		position = quat * Vector3.BACK * distance + get_target().global_position
	
	mouse_delta = Vector2.ZERO
	

func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative.normalized()


# A function to get the current Node3D that the camera should target
func get_target() -> Node3D:
	if use_zoom_target:
		return zoom_target_node
	return target_node
	
	
func clamp_angle(angle : float, min : float, max : float) -> float:
	if angle < -360:
		angle += 360
	if angle > 360:
		angle -= 360
	
	return clampf(angle, min, max)
