shader_type canvas_item;

uniform sampler2D height_map;

const float color_diff = 0.00390625; 
const vec2 dirs_1[] = {
	vec2( 1.0,  0.0),  // E
	vec2( 1.0,  1.0),  // NE
	vec2( 0.0,  1.0),  // N
	vec2(-1.0,  1.0),  // NW
	vec2(-1.0,  0.0),  // W
	vec2(-1.0, -1.0),  // SW
	vec2( 0.0, -1.0),  // S
	vec2( 1.0, -1.0)   // SE
};

bool is_black(vec3 color) {
	return color.r < color_diff && color.g < color_diff && color.b < color_diff;
}

float highest_red_near(sampler2D puddle_map, vec2 uv, vec2 sps) {
	float high_red = -1.0;
	for (int i = 0; i < dirs_1.length(); i++) {
		float red = texture(puddle_map, uv + dirs_1[i] * sps).r;
		high_red = max(red, high_red);
	}
	return high_red; 
}

float lowest_unred_near(sampler2D puddle_map, sampler2D heights, vec2 uv, vec2 sps) {
	float lowest = 2.0;
	for (int i = 0; i < dirs_1.length(); i++) {
		float red = texture(puddle_map, uv + dirs_1[i] * sps).r;
		if (red < color_diff) {
			float height = texture(heights, uv + dirs_1[i] * sps).r;
			lowest = min(height, lowest);
		}
	}
	return lowest; 
}

float lowest_near(sampler2D heights, vec2 uv, vec2 sps) {
	float lowest = 2.0;
	for (int i = 0; i < dirs_1.length(); i++) {
		float height = texture(heights, uv + dirs_1[i] * sps).r;
		lowest = min(height, lowest);
	}
	return lowest;
}

void fragment() {
	vec2 uv = UV;
	vec2 sps = SCREEN_PIXEL_SIZE;
	
	vec3 height_color = texture(height_map, uv).rgb;
	vec3 in_color = texture(TEXTURE, uv).rgb;
	vec3 puddle_color = vec3(0.0, 0.0, in_color.b);
	float near_red = highest_red_near(TEXTURE, uv, sps);
	float near_unred = lowest_unred_near(TEXTURE, height_map, uv, sps);
	
	// Fresh squares, if near a red (flooded) square that is higher, mark red
	if (is_black(in_color)) {
		if (height_color.r <= near_red) {
			puddle_color.r = near_red;
		}
	}
	
	// Stay red
	if (in_color.r > 0.0) {
		puddle_color.r = in_color.r;
	}
	
	// Contained, if this red is the highest and there is higher unflooded
	// Raise this red up to the lowest unflooded nearby height
	if (in_color.r > near_red && in_color.r > 0.0 && near_unred < 1.1) {
		puddle_color.r = max(near_unred, in_color.r);
	}

	
	
	COLOR = vec4(puddle_color, 1.0);
}