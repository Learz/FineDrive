tool
extends VehicleBody
class_name ModularCar

export (PackedScene) var body setget set_body
export (PackedScene) var wheels setget set_wheels
export (Color) var color setget set_color

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
	
func set_color(col : Color):
	color = col
	if $Base/Body_Pos.get_child_count() > 0:
		var material = $Base/Body_Pos.get_child(0).get_child(0).get_surface_material(0)
		material.set_shader_param("base_color", material.get_shader_param("next_color"))
		# FIX : Tween not working, Make tween local
		Global.tween.interpolate_method(self, "shader_param_transition", -1.0, 1.0, 3)
		Global.tween.start()
		material.set_shader_param("next_color", col)
		
func shader_param_transition(value):
	$Base/Body_Pos.get_child(0).get_child(0).get_surface_material(0).set_shader_param("color_transition", value)
