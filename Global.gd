extends Node

const JOYPAD_DEADZONE = 0.5

var controller : Controller

#List of debug variables to display
var debug = {}

# HACK : Doesn't that already exist?
# Look into OS ticks or something
# Time since the game started
var time = 0.0

var left_joypad_vec := Vector2.ZERO
var right_joypad_vec := Vector2.ZERO

var tween = Tween.new()

var UI
var displayHUD = false setget set_display_HUD
var paused = true

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(tween)

func _input(event):
	if event.is_action_pressed("dev_reset"):
		get_tree().reload_current_scene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Joypad vectors cuz godot didn't give us some~
	right_joypad_vec = Vector2.ZERO
	right_joypad_vec = Vector2(Input.get_joy_axis(0, 2), Input.get_joy_axis(0, 3))
	if right_joypad_vec.length() < JOYPAD_DEADZONE:
		right_joypad_vec = Vector2(0, 0)
	else:
		right_joypad_vec = right_joypad_vec.normalized() * ((right_joypad_vec.length() - JOYPAD_DEADZONE) / (1 - JOYPAD_DEADZONE))
	
	left_joypad_vec = Vector2.ZERO
	left_joypad_vec = Vector2(Input.get_joy_axis(0, 0), Input.get_joy_axis(0, 1)) + Vector2(Input.get_action_strength("steer_right")-Input.get_action_strength("steer_left"), Input.get_action_strength("steer_backward")-Input.get_action_strength("steer_forward"))
	left_joypad_vec = left_joypad_vec.clamped(1)
	if left_joypad_vec.length() < JOYPAD_DEADZONE:
		left_joypad_vec = Vector2(0, 0)
	else:
		left_joypad_vec = left_joypad_vec.normalized() * ((left_joypad_vec.length() - JOYPAD_DEADZONE) / (1 - JOYPAD_DEADZONE))
	
	time += delta
	debug["FPS"] = Engine.get_frames_per_second()
#	debug["Resolution"] = get_viewport().size

func set_display_HUD(val):
	displayHUD = val
	UI.visible = displayHUD

func quit():
	get_tree().quit()
