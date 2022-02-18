tool
extends Gacha

export (Color) var color setget set_color
export (String) var color_name

# TODO : Transfer color to global inventory and change car color
func _ready():
	var material = $RigidBody_Bottom/Gacha_Bottom.mesh.surface_get_material(0)
	var instance_material = material.duplicate()
	instance_material.albedo_color = color
	$Content/MeshInstance.set_surface_material(0,instance_material)
	$RigidBody_Bottom/Gacha_Bottom.set_surface_material(0, instance_material)

#func _process(delta):
#	pass

func notify():
	Global.UI.notify("Got a new color!", color_name)

func _on_item_get():
	var ret = ._on_item_get()
	if ret:
		return
	car.set_color(color)

func set_color(v):
	color = v
	_ready()
