extends CanvasLayer

func _unhandled_input(event):
	if event.is_action_pressed("tool_select"):
		$Wheel.show()
	if event.is_action_released("tool_select"):
		var option = $Wheel.get_option()
		$Selection.text = "Selection: %s" % option.name
		$Wheel.hide()
