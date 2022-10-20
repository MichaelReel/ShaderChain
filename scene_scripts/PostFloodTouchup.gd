extends Node2D


signal viewport_captured(image)

onready var viewport : Viewport = $Viewport
onready var texture_rect : TextureRect = $Viewport/TextureRect
onready var mat : ShaderMaterial = texture_rect.material

func _process(_delta) -> void:
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		print("capture")
		capture_viewport_image()

func capture_viewport_image() -> void:
	viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(VisualServer, "frame_post_draw")
	var img = viewport.get_texture().get_data()
	
	# Debug
	var err = img.save_png("res://output/debug_postflood.png")
	if err != OK:
		push_error("Failed to save output image: " + str(err))

	emit_signal("viewport_captured", img)

