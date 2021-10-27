extends Spatial
class_name Gacha

export (Curve) var trajectory

var got = false
var collided = false
var time = 0.0
var dur = 3
onready var original_position = $Content.global_transform.origin

var car : ModularCar = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if collided:
		time = min(time+delta,dur)
		$Content.global_transform.origin.x = lerp(original_position.x, car.global_transform.origin.x, time/dur)
		$Content.global_transform.origin.y = lerp(original_position.y, car.global_transform.origin.y, time/dur) + trajectory.interpolate(time/dur)*2
		$Content.global_transform.origin.z = lerp(original_position.z, car.global_transform.origin.z, time/dur)
		$Content.rotate(Vector3(0,1,0), 2*delta)
		if time == 3:
			$RigidBody_Bottom/Gacha_Bottom.scale -= Vector3(0.2,0.2,0.2) * delta
			$RigidBody_Top/Gacha_Top.scale -= Vector3(0.2,0.2,0.2) * delta
			if $RigidBody_Bottom/Gacha_Bottom.scale <= Vector3.ZERO:
				queue_free()
			_on_item_get()

func _on_item_get():
	if got:
		return
	got = true

func _on_HitArea_body_entered(body):
	if body.has_meta("car") and not collided:
		car = body
		$RigidBody_Bottom.mode = RigidBody.MODE_RIGID
		$RigidBody_Top.mode = RigidBody.MODE_RIGID
		$RigidBody_Bottom.set_collision_mask_bit(0,true)
		$RigidBody_Top.set_collision_mask_bit(0,true)
		collided = true
