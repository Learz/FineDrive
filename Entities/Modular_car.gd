tool
extends VehicleBody
class_name ModularCar

export (PackedScene) var body setget set_body
export (PackedScene) var wheels setget set_wheels

var all_wheels = [$Wheel_Front_L_Pos, $Wheel_Front_R_Pos, $Wheel_Rear_L_Pos, $Wheel_Rear_R_Pos]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		pass
	else:
		pass

func set_body(v):
	if $Base/Body_Pos.get_child_count() > 0:
		$Base/Body_Pos.get_child(0).queue_free()
	$Base/Body_Pos.add_child(v.instance())
	body = v

func set_wheels(v):
	for wheel in all_wheels:
		if wheel.get_child_count() > 0:
			wheel.get_child(0).queue_free()
		wheel.add_child(v.instance())
	$Wheel_Front_R_Pos.get_child(0).rotate_y(3.14159)
	$Wheel_Rear_R_Pos.get_child(0).rotate_y(3.14159)
	wheels = v
