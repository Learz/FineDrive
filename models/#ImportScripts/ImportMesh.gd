tool # Needed so it runs in the editor.
extends EditorScenePostImport

var sphere_col_template = load("res://models/#ImportScripts/SphereCollisionTemplate.tscn")
var rootScene

func post_import(scene):
	rootScene = scene
	iterate(scene)
	return scene # remember to return the imported scene	

func iterate(node):
	if node != null:
		if "-colonly" in node.name and node is Spatial:
			var new_node = sphere_col_template.instance()
			new_node.name = "phys_" + node.get_parent().name
			new_node.transform = node.get_parent().transform
			rootScene.add_child(new_node)
			new_node.owner = rootScene
			var move_parent = node.get_parent()
			rootScene.remove_child(node.get_parent())
			new_node.add_child(move_parent)
			move_parent.owner = rootScene
			node.queue_free()
		for child in node.get_children():
			iterate(child)
