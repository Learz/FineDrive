extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var notifications = []

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.UI = self
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$DebugInfo.text = ""
	for key in Global.debug:
		var value = Global.debug[key]
		$DebugInfo.text += key + " : " + String(value) + "\n"

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
