tool # Needed so it runs in the editor.
extends EditorScenePostImport

var material = load("res://models/Modular_Car/Modular_Car_Mat.tres")

func post_import(scene):
	scene.get_child(0).set_surface_material(0, material)
	return scene # remember to return the imported scene	
