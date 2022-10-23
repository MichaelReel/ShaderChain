shader_type canvas_item;


uniform sampler2D height_map;
uniform sampler2D flow_map;
uniform float blend = 0.5;

void fragment() {
	vec2 uv = UV;
	
	vec4 height_color = texture(height_map, uv);
	vec4 flow_color = texture(flow_map, uv);
	
	vec4 blended_color = mix(height_color, flow_color, blend);
//	vec4 blended_color = vec4(flow_color.rg, height_color.b, 1.0);
	
	COLOR = blended_color;
}