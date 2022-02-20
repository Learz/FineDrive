extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var notifications = []

var mode = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.UI = self
	$Debug/Monitor.os_time_per_frame()
	$Debug/Monitor.add_perf_monitor(Performance.TIME_FPS, "FPS")
	$Debug/Monitor.add_perf_monitor(Performance.MEMORY_DYNAMIC, "Memory", Color(0.2, 1, 0.2, 0.5), true)

func _input(event):
	if(event is InputEventKey):
		if event.is_action_pressed("ui_debug"):
			$Debug.visible = !$Debug.visible
		for prompt in $Prompts.get_children():
			prompt.set_glyph_mode(1)
	elif(event is InputEventJoypadButton):
		for prompt in $Prompts.get_children():
			prompt.set_glyph_mode(0)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#FIX : Unprojected position isn't right when resizing window
	Global.debug["Viewport test"] = get_viewport().get_camera().unproject_position(Global.controller.car.global_transform.origin) / get_viewport().size
	$DebugMarker.rect_position = get_viewport().get_camera().unproject_position(Global.controller.car.global_transform.origin)
	
	$Debug/DebugInfo.text = ""
	for key in Global.debug:
		var value = Global.debug[key]
		$Debug/DebugInfo.text += key + " : " + String(value) + "\n"

func notify(title, description):
	if $UIAnimator.is_playing() and $UIAnimator.current_animation == "Notification":
		notifications.append({"title" : title, "description" : description})
	else:
		$Notification/VBoxContainer/Title.text = title
		$Notification/VBoxContainer/Description.text = description
		$UIAnimator.play("Notification")


func _on_UIAnimator_animation_finished(anim_name):
	if anim_name == "Notification" and notifications.size() > 0:
		var next_notification = notifications.pop_front()
		$Notification/VBoxContainer/Title.text = next_notification["title"]
		$Notification/VBoxContainer/Description.text = next_notification["description"]
		$UIAnimator.play("Notification")
