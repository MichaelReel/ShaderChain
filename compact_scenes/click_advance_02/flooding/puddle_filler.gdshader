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

float lowest_red_near(sampler2D puddle_map, vec2 uv, vec2 sps) {
	float lowest = 2.0;
	for (int i = 0; i < dirs_1.length(); i++) {
		float red = texture(puddle_map, uv + dirs_1[i] * sps).r;
		lowest = min(red, lowest);
	}
	return lowest; 
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
	
	float height = texture(height_map, uv).r;
	vec3 in_color = texture(TEXTURE, uv).rgb;
	float high_near_red = highest_red_near(TEXTURE, uv, sps);
	float low_near_red = lowest_red_near(TEXTURE, uv, sps);
	float low_near_unred = lowest_unred_near(TEXTURE, height_map, uv, sps);
	
	vec3 puddle_color = vec3(0.0, 0.0, 0.0);
	
	// Fresh squares, if near a red (flooded) square that is higher, mark red
	if (is_black(in_color)) {
		if (height < high_near_red) {
			puddle_color.r = high_near_red;
		}
	}
	
	// Stay red
	if (in_color.r > 0.0) {
		puddle_color.r = in_color.r;
	}
	
	COLOR = vec4(puddle_color, 1.0);
}