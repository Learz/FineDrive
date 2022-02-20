tool # Needed so it runs in the editor.
extends EditorScenePostImport

var wheel_template = load("res://models/#ImportScripts/VehicleWheel.tscn")
var collision_shape = load("res://models/#ImportScripts/RegularCarCollisionShape.tscn")
var rootScene

#TODO (Unrelated to script) Try changing center of gravity of car (model)
func post_import(scene):
	rootScene = scene
	iterate(scene)
	var new_node = collision_shape.instance()
	new_node.name = "CollisionShape"
	rootScene.add_child(new_node)
	new_node.owner = rootScene
	return scene # remember to return the imported scene	
	
func iterate(node):
	if node != null:
		if "wheel" in node.name and not node is VehicleWheel:
			var new_node = wheel_template.instance() as VehicleWheel
			new_node.name = "phys_" + node.name
			new_node.transform.origin = node.transform.origin
			rootScene.add_child(new_node)
			new_node.owner = rootScene
			node.get_parent().remove_child(node)
			new_node.add_child(node)
			node.owner = rootScene
			node.transform = node.transform.rotated(Vector3(0,1,0), deg2rad(180))
			node.transform.origin = Vector3.ZERO
			if "front" in node.name:
				new_node.use_as_steering = true
			if "back" in node.name:
				new_node.use_as_traction = true
		elif "body" in node.name:
			node.get_parent().remove_child(node)
			rootScene.add_child(node)
			node.owner = rootScene
			node = node as MeshInstance
		elif node != rootScene:
			node.get_parent().remove_child(node)
		for child in node.get_children():
			iterate(child)
