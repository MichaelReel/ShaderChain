extends Control


const CLICK_SPEED : float = 0.5

onready var display := $DisplayTextureRect
onready var repeat_delay_timer := $RepeatDelayTimer

onready var shader_path_config : Array = [
	{"root": $HeightMap/NoiseMap, "capture": "noise_map"},
	{"root": $HeightMap/EdgeFade, "texture" : "noise_map", "capture": "edge_fade"},
	{"root": $HeightMap/HeightAdjust, "texture": "edge_fade", "capture": "height_adjust"},
	{
		"root": $Flooding/DepressionPoints,
		"texture": "height_adjust",
		"capture": "depression_points",
	},
	{
		"root": $Flooding/PuddleFiller,
		"texture": "depression_points",
		"shader_textures": {"height_map": "height_adjust"},
		"feedback": "counter",
		"min_feedback": 2,
		"capture": "puddles",
	},
	{
		"root": $Merging,
		"shader_textures": {
			"height_map": "height_adjust",
			"puddle_map": "puddles",
		},
	}
]

var captures : Dictionary = {}

var current_index : int = -1
var current_root : Control
var current_viewport : Viewport
var repeat_hash : String = ""
var repeat_counter : int = 0;

var click_wait := CLICK_SPEED


func _ready():
	_advance()

func _advance():
	# check we have more configurations to go
	if current_index >= len(shader_path_config) - 1:
		return
	
	# Index the next shader
	current_index += 1
	current_root = shader_path_config[current_index]["root"]
	current_viewport = current_root.get_node("Viewport")
	
	# Set a new texture, from captured images, if configured to do so
	if "texture" in shader_path_config[current_index]:
		var current_texture_rect : TextureRect = current_viewport.get_node("TextureRect")
		var capture_name : String = shader_path_config[current_index]["texture"]
		var texture = _get_captured_texture(capture_name)
		current_texture_rect.texture = texture
	
	if "shader_textures" in shader_path_config[current_index]:
		var current_texture_rect : TextureRect = current_viewport.get_node("TextureRect")
		var shader_textures = shader_path_config[current_index]["shader_textures"]
		for uniform_name in shader_textures:
			var capture_name : String = shader_textures[uniform_name]
			var texture = _get_captured_texture(capture_name)
			current_texture_rect.material.set_shader_param(uniform_name, texture)
		
	if "3d_shader_textures" in shader_path_config[current_index]:
		var current_mesh_instance : MeshInstance = current_viewport.get_node("MeshInstance")
		var shader_textures = shader_path_config[current_index]["3d_shader_textures"]
		for uniform_name in shader_textures:
			var capture_name : String = shader_textures[uniform_name]
			var texture = _get_captured_texture(capture_name)
			current_mesh_instance.mesh.material.set_shader_param(uniform_name, texture)
	
	# Switch display to show the current viewport
	display.texture = current_viewport.get_texture()
	
	if "feedback" in shader_path_config[current_index]:
		repeat_counter = 0
		print ("starting feedback")
		repeat_delay_timer.start()

func _on_RepeatDelayTimer_timeout():
	var current_texture_rect : TextureRect = current_viewport.get_node("TextureRect")
	var viewport : Viewport = current_viewport
	# get material and use the "feedback" name to pass the incremented repeat_counter value
	
	viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	# Wait until the frame has finished before getting the texture.
	yield(VisualServer, "frame_post_draw")
	
	# Retrieve the captured image.
	var repeat_img : Image = viewport.get_texture().get_data()
	
	# If we're passed the minimum frames, hash the image and check for matches
	if (
		not "min_feedback" in shader_path_config[current_index] 
		or shader_path_config[current_index]["min_feedback"] < repeat_counter
	):
		var hash_code := hash_data(repeat_img.get_data())
		if hash_code == repeat_hash:
			# Got 2 frames the same, let's stop
			repeat_delay_timer.stop()
			repeat_hash = ""
			print("Repetition stopped by duplication after " + str(repeat_counter) + " frames")
			return
		repeat_hash = hash_code
	
	# Setting up next iteration
	print (str(repeat_counter))
	var feedback_uniform = shader_path_config[current_index]["feedback"]
	current_texture_rect.material.set_shader_param(feedback_uniform, repeat_counter)
	repeat_counter += 1
	
	# Create the texture to act as input for the next interation
	var texture = ImageTexture.new()
	texture.create_from_image(repeat_img)
	current_texture_rect.texture = texture
	

func hash_data(data: PoolByteArray) -> String:
	# Start a SHA-256 context.
	var ctx = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(data)
	# Get the computed hash.
	var res = ctx.finish()
	return res.hex_encode()

func _get_captured_texture(var capture_name : String) -> ImageTexture:
	var capture_img : Image = captures[capture_name]
	var texture = ImageTexture.new()
	texture.create_from_image(capture_img)
	return texture

func _process(delta):
	click_wait -= delta
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and click_wait <= 0.0:
		# Don't redraw anything, we're already moving on
		repeat_delay_timer.stop()
		# Capture the current viewport and delay lingering clicks
		
		if "capture" in shader_path_config[current_index]:
			print("capturing " + current_root.name)
			_capture_viewport_image()
		else:
			_advance()
		
		click_wait = CLICK_SPEED

func _capture_viewport_image() -> void:
	current_viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	# Wait until the frame has finished before getting the texture.
	yield(VisualServer, "frame_post_draw")
	
	# Retrieve the captured image.
	var img = current_viewport.get_texture().get_data()
	var capture_name = shader_path_config[current_index]["capture"]
	
	# Store it incase we need it later
	captures[capture_name] = img
	
	# Only advance after we've recorded the image,
	# moving _advance call up to the calling _process causes it to be performed early
	_advance()

