extends Camera


func _input(event) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_WHEEL_UP:
			fov -= 0.1
			print(str(fov))
		if event.button_index == BUTTON_WHEEL_DOWN:
			fov += 0.1
			print(str(fov))
