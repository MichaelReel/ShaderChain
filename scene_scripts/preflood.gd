extends Node2D


signal viewport_captured(image)

onready var viewport : Viewport = $Viewport
onready var texture_rect : TextureRect = $Viewport/TextureRect
onready var mat : ShaderMaterial = texture_rect.material

var max_green : float = 0.0;
var min_green : float = 1.0;
var max_edge : float = 0.0;

func _ready() -> void:
	# Find min and max values in tecture image (not terribly fast)
	var image_data : Image = texture_rect.texture.get_data()
	image_data.lock()
	for y in range(image_data.get_height()):
		for x in range(image_data.get_width()):
			var datum = image_data.get_pixel(x, y);
			max_green = max(datum.g, max_green)
			min_green = min(datum.g, min_green)
			if x <= 0 or y <= 0 or x >= 2047 or y >= 2047:
				max_edge = max(datum.g, max_edge)
			
	image_data.unlock()
	print("Min/Mix intesity: " + str(min_green) + ", " + str(max_green))

func _process(_delta) -> void:
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		print("capture")
		capture_viewport_image()
	
	# Set shader properties
	mat.set_shader_param("min_intensity", min_green)
	mat.set_shader_param("max_intensity", max_green)
	mat.set_shader_param("max_edge", max_edge)

func capture_viewport_image() -> void:
	viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	# Wait until the frame has finished before getting the texture.
	yield(VisualServer, "frame_post_draw")
	
	# Retrieve the captured image.
	var img = viewport.get_texture().get_data()
	
	# Debug
	var err = img.save_png("res://output/debug_preflood.png")
	if err != OK:
		push_error("Failed to save output image: " + str(err))

	emit_signal("viewport_captured", img)

