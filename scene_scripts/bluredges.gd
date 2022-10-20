extends Node2D


signal viewport_captured(image)

onready var viewport : Viewport = $Viewport
onready var texture_rect : TextureRect = $Viewport/TextureRect
onready var mat : ShaderMaterial = texture_rect.material

func _process(_delta):
	# Get shader properties
	var mouse = get_global_mouse_position() / texture_rect.get_rect().size;
	
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		print("capture")
		capture_viewport_image()
	
	# Set shader properties
	mat.set_shader_param("Mouse", mouse)

func capture_viewport_image() -> void:
	viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	# Wait until the frame has finished before getting the texture.
	yield(VisualServer, "frame_post_draw")
	
	# Retrieve the captured image.
	var img = viewport.get_texture().get_data()
	
	# Debug
	var err = img.save_png("res://output/debug_blur_edges.png")
	if err != OK:
		push_error("Failed to save output image: " + str(err))

	emit_signal("viewport_captured", img)

