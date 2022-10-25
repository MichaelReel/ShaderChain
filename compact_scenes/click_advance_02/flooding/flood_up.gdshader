shader_type canvas_item;

uniform sampler2D height_map;

const float color_diff = 0.00390625; 

bool is_black(vec3 color) {
	return color.r < color_diff && color.g < color_diff && color.b < color_diff;
}

void fragment() {
	vec2 uv = UV;
	vec3 height_color = texture(height_map, uv).rgb;
	vec3 return_color = texture(TEXTURE, uv).rgb;
	
	if (is_black(return_color)) {
		return_color = height_color;
	} else {
		return_color = vec3(1.0, 0.0, 1.0);
	}
	
	COLOR = vec4(return_color, 1.0);
}