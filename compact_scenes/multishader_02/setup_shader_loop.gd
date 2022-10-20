extends Node2D


onready var repeat_viewport := $RepeatViewport
onready var input_texture_rect := $Viewport/TextureRect

func _on_Timer_timeout():
	# Redirect the textureRect to create a viewport loop
	# Give some time to let the previous shaders a little time
	input_texture_rect.texture = repeat_viewport.get_texture()
