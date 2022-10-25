shader_type canvas_item;

uniform sampler2D height_map;
uniform sampler2D down_flow_map;
uniform sampler2D up_flow_map;
uniform sampler2D pool_map;

void fragment() {
	vec2 uv = UV;
	
	float height = texture(height_map, uv).r;
	vec4 down_flow_color = texture(down_flow_map, uv);
	vec4 up_flow_color = texture(up_flow_map, uv);
	vec4 pool_color = texture(pool_map, uv);
	
	vec3 result = vec3(0.0);

	if (down_flow_color.r > 0.0 || down_flow_color.g > 0.0 || down_flow_color.b > 0.0) {
		result = vec3(0.0, 0.0, height);
	} else if (up_flow_color.r > 0.0 || up_flow_color.g > 0.0 || up_flow_color.b > 0.0) {
		result = vec3(0.0, 0.0, height);
	} else if (pool_color.r >= 0.5 && pool_color.g >= 0.5 && pool_color.b >= 0.5) {
		result = vec3(0.0, 0.0, height);
	} else {
		result = vec3(0.0, height, 0.0);
	}
	
	COLOR = vec4(result, 1.0);
}