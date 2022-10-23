extends Node2D


onready var input_texture_rect := $WaterFlowViewport/InputTextureRect
onready var repeater_viewport := $RepeaterViewport

func _on_RepeatStartTimer_timeout():
	input_texture_rect.texture = repeater_viewport.get_texture()
