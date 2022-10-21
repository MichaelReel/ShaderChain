extends Node2D


onready var repeat_viewport := $RepeaterViewport
onready var input_texture_rect := $FlowNoiseViewport/TextureRect


func _on_LoopStartTimer_timeout():
	input_texture_rect.texture = repeat_viewport.get_texture()
