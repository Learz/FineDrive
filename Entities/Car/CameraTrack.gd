extends Spatial

export(NodePath) var track_object

var controller
var rotation_offset := Vector3.ZERO
var camera_rotation_speed = 1

const IDLE_TIME = 5
var idle_timer = 5


# Called when the node enters the scene tree for the first time.
func _ready():
	track_object = get_node(track_object)
	controller = get_parent()


# TODO : Better camera tracking
func _physics_process(delta):
	transform.origin = lerp(transform.origin, track_object.transform.origin, delta*10.0)
	rotation.y = lerp_angle(rotation.y, track_object.rotation.y, delta*10.0)
	
	# Start and idle timer if the camera controls are untouched
	if Global.right_joypad_vec.length() == 0:
		idle_timer = max(idle_timer-delta, 0)
	else:
		idle_timer = IDLE_TIME
	
	# Set the rotation based on the joystick position
	rotation_offset.y = clamp(rotation_offset.y + Global.right_joypad_vec.x * camera_rotation_speed * delta, -0.3, 0.3)
	rotation_offset.x = clamp(rotation_offset.x - Global.right_joypad_vec.y * camera_rotation_speed * delta, -0.6, 0.6)
	Global.debug["rotation offset"] = rotation_offset
	rotation.x = rotation_offset.x
	rotation.y += rotation_offset.y
	
	# Return the camera to the original position after being inactive for IDLE_TIME seconds
	if idle_timer == 0:
		rotation_offset.y = lerp_angle(rotation_offset.y, 0, (delta*2))
		rotation_offset.x = lerp_angle(rotation_offset.x, 0, (delta*2))
	# Return the camera to the original position if the car starts accelerating
	else:
		rotation_offset.y = lerp_angle(rotation_offset.y, 0, (delta*5)*(controller.speed/controller.MAX_SPEED))
		rotation_offset.x = lerp_angle(rotation_offset.x, 0, (delta*5)*(controller.speed/controller.MAX_SPEED))
