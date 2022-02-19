extends Node
class_name Controller

export (Curve) var acceleration_curve : Curve
export (Curve) var turning_curve : Curve

onready var car = $Car_Base as ModularCar
onready var wheel_frontLeft := $Car_Base/Wheel_Front_L_Pos
onready var wheel_frontRight := $Car_Base/Wheel_Front_R_Pos
onready var wheel_backLeft := $Car_Base/Wheel_Rear_L_Pos
onready var wheel_backRight := $Car_Base/Wheel_Rear_R_Pos

const MAX_ENGINE_FORCE = 300.0
const MAX_SPEED = 50.0
const MAX_BRAKE = 5.0
const MAX_STEERING = 1.0
const JUMP_FORCE = 200.0
const AIR_CONTROL_FORCE = 3.0

var speed = 0
var jumpCount = 0

var steering_target = 0
var friction_target = 0

enum STATE {IDLE, ACCELERATING, BRAKING, REVERSING, JUMPING, DRIFTING}
var state = STATE.IDLE


func _ready():
	Global.controller = self
	car.set_meta("car", true)


func _process(delta):
	if Global.paused:
		return
	# Forward speed based on the direction of the vehicle
	speed = car.global_transform.basis.xform_inv(car.linear_velocity).z*-3.6
	
	# HACK : Should probably not reset everything every cycle, look into it
	# Idle state (reset all car vars)
	state = STATE.IDLE
	car.engine_force = 0
	car.brake = 0
	
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
			steering_target = Input.get_action_strength("steer_left") * MAX_STEERING * turning_curve.interpolate(abs(speed)/MAX_SPEED)
		elif Input.is_action_pressed("steer_right"):
			steering_target = Input.get_action_strength("steer_right") * -MAX_STEERING * turning_curve.interpolate(abs(speed)/MAX_SPEED)
		else:
			steering_target = 0
			
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
#		else:
#			wheel_frontLeft.wheel_friction_slip = 10.5
#			wheel_frontRight.wheel_friction_slip = 10.5
#			wheel_backLeft.wheel_friction_slip = 10.5
#			wheel_backRight.wheel_friction_slip = 10.5
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
	
	if state == STATE.DRIFTING:
		$Car_Base/ParticlesLeft.emitting = wheel_backLeft.is_in_contact()
		$Car_Base/ParticlesRight.emitting = wheel_backRight.is_in_contact()
	else:
		$Car_Base/ParticlesLeft.emitting = false
		$Car_Base/ParticlesRight.emitting = false
	
	Global.debug["Speed"] = "%05.2f" % float(car.linear_velocity.length()*3.6)
	Global.debug["KM/H"] = speed
	Global.debug["Wheel Rotation"] = car.steering
	Global.debug["State"] = STATE.keys()[state]

func _physics_process(delta):
	car.steering = lerp(car.steering, steering_target, delta * 10.0)
	
	#If drifting stopped, slowly get traction back to normal
	if state != STATE.DRIFTING:
		wheel_frontLeft.wheel_friction_slip = lerp(wheel_frontLeft.wheel_friction_slip, 10.5, delta * 0.2)
		wheel_frontRight.wheel_friction_slip = lerp(wheel_frontRight.wheel_friction_slip, 10.5, delta * 0.2)
		wheel_backLeft.wheel_friction_slip = lerp(wheel_backLeft.wheel_friction_slip, 10.5, delta * 0.2)
		wheel_backRight.wheel_friction_slip = lerp(wheel_backRight.wheel_friction_slip, 10.5, delta * 0.2)

# Return true if any wheel is touching the ground
func wheel_on_ground():
	return (wheel_frontLeft.is_in_contact() or wheel_frontRight.is_in_contact() or wheel_backLeft.is_in_contact() or wheel_backRight.is_in_contact())

