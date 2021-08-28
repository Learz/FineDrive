extends Node
class_name Controller

export (Curve) var acceleration_curve : Curve
export (Curve) var turning_curve : Curve

onready var car = $sedan as VehicleBody
onready var wheel_frontLeft := $sedan/phys_wheel_frontLeft
onready var wheel_frontRight := $sedan/phys_wheel_frontRight
onready var wheel_backLeft := $sedan/phys_wheel_backLeft
onready var wheel_backRight := $sedan/phys_wheel_backRight

const MAX_ENGINE_FORCE = 300.0
const MAX_SPEED = 50.0
const MAX_BRAKE = 5.0
const MAX_STEERING = 0.5
const JUMP_FORCE = 200.0
const AIR_CONTROL_FORCE = 3.0

var speed = 0
var jumpCount = 0

enum STATE {IDLE, ACCELERATING, BRAKING, REVERSING, JUMPING, DRIFTING}
var state = STATE.IDLE

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.controller = self
	car.set_meta("car", true)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Forward speed based on the direction of the vehicle
	speed = car.global_transform.basis.xform_inv(car.linear_velocity).z*-3.6
	
	# HACK : Should probably not reset everything every cycle, look into it
	# Idle state (reset all car vars)
	state = STATE.IDLE
	car.engine_force = 0
	car.brake = 0
	car.steering = 0
	
	if wheel_on_ground():
		# Reset the jump counter (double jump)
		jumpCount = 0
		
		#--SPEED CONTROL--
		if Input.is_action_pressed("brake"):
			if speed > 1:
				car.brake = Input.get_action_strength("brake") * MAX_BRAKE
				state = STATE.BRAKING
			else:
				car.engine_force = -Input.get_action_strength("brake") * acceleration_curve.interpolate(abs(speed)/MAX_SPEED*2) * MAX_ENGINE_FORCE
				state = STATE.REVERSING
		
		if Input.is_action_pressed("accelerate"):
			car.engine_force = Input.get_action_strength("accelerate") * acceleration_curve.interpolate(abs(speed)/MAX_SPEED) * MAX_ENGINE_FORCE
			state = STATE.ACCELERATING
		
		# Auto-braking for better platforming
		if state == STATE.IDLE:
			car.brake = MAX_BRAKE / 4.0
		
		#--STEERING--
		if Input.is_action_pressed("steer_left"):
			car.steering = Input.get_action_strength("steer_left") * MAX_STEERING * turning_curve.interpolate(abs(speed)/MAX_SPEED)
		if Input.is_action_pressed("steer_right"):
			car.steering = Input.get_action_strength("steer_right") * -MAX_STEERING * turning_curve.interpolate(abs(speed)/MAX_SPEED)
	
		#--ACTIONS--
		if Input.is_action_just_pressed("jump") and wheel_on_ground():
			car.apply_central_impulse(Vector3(0,JUMP_FORCE,0))
			state = STATE.JUMPING
		
		# TODO : Working drift system lol
		# What a mess
		if Input.is_action_just_pressed("drift"):
			# Jump and shift to the side, mario kart style
			car.apply_central_impulse(Vector3(0,JUMP_FORCE/5,0))
			car.apply_impulse(Vector3(0,0,-1), Vector3(Global.left_joypad_vec.x*10,0,0))
		if Input.is_action_pressed("drift"):
			state = STATE.DRIFTING
			wheel_frontLeft.wheel_friction_slip = 4
			wheel_frontRight.wheel_friction_slip = 4
			
			wheel_backLeft.wheel_friction_slip = 2
			wheel_backRight.wheel_friction_slip = 2
			# If not going faster than half the max speed in any direction, apply impulse to help drift
			if car.linear_velocity.length()*3.6 < MAX_SPEED / 2:
				car.apply_central_impulse(car.global_transform.basis * Vector3(Global.left_joypad_vec.x*10,0,-MAX_SPEED/5))
		else:
			wheel_frontLeft.wheel_friction_slip = 10.5
			wheel_frontRight.wheel_friction_slip = 10.5
			wheel_backLeft.wheel_friction_slip = 10.5
			wheel_backRight.wheel_friction_slip = 10.5
	else:
		state = STATE.JUMPING
		var ljv = Global.left_joypad_vec
		#AIR STEERING
		if car.linear_velocity.length()*3.6 < MAX_SPEED:
			car.apply_central_impulse(car.global_transform.basis * Vector3(ljv.x,0,ljv.y) * AIR_CONTROL_FORCE)
			car.apply_impulse(Vector3(0,0,1), Vector3(-ljv.x,0,0))
		# Mid-air double jump controls
		# Shift the car in the direction of the left joystick
		if Input.is_action_just_pressed("jump") and jumpCount <= 0:
			jumpCount += 1
			car.apply_central_impulse(car.global_transform.basis * Vector3(ljv.x*JUMP_FORCE,0,ljv.y*JUMP_FORCE) + Vector3(0,JUMP_FORCE*(1-ljv.length()),0))
	
	
	Global.debug["Speed"] = "%05.2f" % float(car.linear_velocity.length()*3.6)
	Global.debug["KM/H"] = speed
	Global.debug["Wheel Rotation"] = car.steering
	Global.debug["State"] = STATE.keys()[state]

# Return true if any wheel is touching the ground
func wheel_on_ground():
	return (wheel_frontLeft.is_in_contact() or wheel_frontRight.is_in_contact() or wheel_backLeft.is_in_contact() or wheel_backRight.is_in_contact())

