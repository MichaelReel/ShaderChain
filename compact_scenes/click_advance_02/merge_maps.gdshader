shader_type canvas_item;


uniform sampler2D height_map;
uniform sampler2D puddle_map;
uniform float blend = 0.5;

void fragment() {
	vec2 uv = UV;
	
	vec4 map_height = texture(height_map, uv);
	vec4 flow_color = texture(puddle_map, uv);
	
	vec4 blended_color = map_height;
	if (flow_color.r > map_height.r) {
		blended_color = flow_color;
	}
	
	COLOR = blended_color;
}