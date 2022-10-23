shader_type canvas_item;


uniform sampler2D height_map;
uniform sampler2D flow_map;
uniform sampler2D point_map;

void fragment() {
	vec2 uv = UV;
	
	vec4 flow_color = texture(flow_map, uv);
	vec4 point_color = texture(point_map, uv);
	
	vec3 result = vec3(0.0);
	if (point_color.r > 0.0 || point_color.g > 0.0 || point_color.b > 0.0) {
		result = vec3(1.0, 1.0, 1.0);
	} else if (flow_color.r > 0.0 || flow_color.g > 0.0 || flow_color.b > 0.0) {
		result = vec3(0.0, 0.0, 1.0);
	} 
	
	COLOR = vec4(result, 1.0);
}