extends Spatial

export (Curve) var trajectory

var collided = false
var time = 0.0
onready var original_position = $Content.global_transform.origin


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if collided:
		time = min(time+delta,3)
		$Content.global_transform.origin.x = lerp(original_position.x, Global.controller.car.global_transform.origin.x, time/3)
		$Content.global_transform.origin.y = original_position.y + trajectory.interpolate(time/3)*2
		$Content.global_transform.origin.z = lerp(original_position.z, Global.controller.car.global_transform.origin.z, time/3)
		$Content.rotate(Vector3(0,1,0), 2*delta)
#		if time == 3:
#			$RigidBody_Bottom/Gacha_Bottom.scale -= Vector3(0.2,0.2,0.2) * delta
#			$RigidBody_Top/Gacha_Top.scale -= Vector3(0.2,0.2,0.2) * delta
#			if $RigidBody_Bottom/Gacha_Bottom.scale <= Vector3.ZERO:
#				queue_free()

func _on_HitArea_body_entered(body):
	if body.has_meta("car") and not collided:
		$RigidBody_Bottom.mode = RigidBody.MODE_RIGID
		$RigidBody_Top.mode = RigidBody.MODE_RIGID
		$RigidBody_Bottom.set_collision_mask_bit(0,true)
		$RigidBody_Top.set_collision_mask_bit(0,true)
		collided = true
