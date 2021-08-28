extends Spatial
class_name Shine

var origin := Vector3(0,0,0)
var life = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	origin = translation
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if life == -1:
		rotate(Vector3(0,1,0), 1*delta)
		rotate(Vector3(0,0,1), 0.6*delta)
		rotate(Vector3(1,0,0), 0.3*delta)
		translation = origin + Vector3(0,sin(Global.time*1.5)/8,0)
	if life != -1:
		if life >= 0:
			life -= delta
		if life <= 0:
			queue_free()
	
func shine_get():
	if life != -1:
		return
	$Particles.restart()
	$Icosphere.hide()
	life = $Particles.lifetime

func _on_Area_body_entered(body):
	if body.has_meta("car"):
		shine_get()
