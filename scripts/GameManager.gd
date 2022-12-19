extends Node


enum State {
	PLAY,
	INTERACT,
	PAUSE
}

var state : State = State.PLAY
var cam_trans : Transform3D = Transform3D.IDENTITY

@onready var camera : CameraOrbit


func _ready():
	camera = get_viewport().get_camera_3d()
	change_state(State.PLAY)


func change_state(new_state : State, cam_trans = Transform3D.IDENTITY) -> void:
	print("Game state is changing, from " + str(state) + " to " + str(new_state))
	state = new_state
	match state:
		State.PLAY:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			camera.stop_camera = false
		State.INTERACT:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			camera.stop_camera = true
			self.cam_trans = cam_trans
		State.PAUSE:
			pass


func _process(delta):
	match state:
		State.INTERACT:
			camera.global_transform = cam_trans
			
func _input(event):
	if event.is_action_pressed("free_mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
