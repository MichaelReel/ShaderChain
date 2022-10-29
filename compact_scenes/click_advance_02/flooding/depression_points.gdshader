shader_type canvas_item;

const float color_diff = 0.001953125;
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
const vec2 dirs_2[] = {
	vec2( 2.0,  0.0),  // E
	vec2( 2.0,  1.0),
	vec2( 2.0,  2.0),  // NE
	vec2( 1.0,  2.0),
	vec2( 0.0,  2.0),  // N
	vec2(-1.0,  2.0),
	vec2(-2.0,  2.0),  // NW
	vec2(-2.0,  1.0),
	vec2(-2.0,  0.0),  // W
	vec2(-2.0, -1.0),
	vec2(-2.0, -2.0),  // SW
	vec2(-1.0, -2.0),
	vec2( 0.0, -2.0),  // S
	vec2( 1.0, -2.0),
	vec2( 2.0, -2.0),  // SE
	vec2( 2.0, -1.0)
};
const vec2 dirs_3[] = {
	vec2( 3.0,  0.0),  // E
	vec2( 3.0,  1.0),
	vec2( 3.0,  2.0),
	vec2( 3.0,  3.0),  // NE
	vec2( 2.0,  3.0),
	vec2( 1.0,  3.0),
	vec2( 0.0,  3.0),  // N
	vec2(-1.0,  3.0),
	vec2(-2.0,  3.0),
	vec2(-3.0,  3.0),  // NW
	vec2(-3.0,  2.0),
	vec2(-3.0,  1.0),
	vec2(-3.0,  0.0),  // W
	vec2(-3.0, -1.0),
	vec2(-3.0, -2.0),
	vec2(-3.0, -3.0),  // SW
	vec2(-2.0, -3.0),
	vec2(-1.0, -3.0),
	vec2( 0.0, -3.0),  // S
	vec2( 1.0, -3.0),
	vec2( 2.0, -3.0),
	vec2( 3.0, -3.0),  // SE
	vec2( 3.0, -2.0),
	vec2( 3.0, -1.0)
};


vec4 get_neighbour_color(vec2 uv, vec2 sps, sampler2D tex, vec2 dxy) {
	vec2 neighbour = uv + dxy * sps;
	return texture(tex, neighbour);
}

bool lowest_of_9(sampler2D tex, vec2 uv, vec2 sps) {
	float local_red = texture(tex, uv).r;
	for (int i = 0; i < dirs_1.length(); i++){
		float red = get_neighbour_color(uv, sps, tex, dirs_1[i]).r;
		if (red >= local_red) {
			return false;
		}
	}
	return true;
}

bool lowest_of_25(sampler2D tex, vec2 uv, vec2 sps) {
	if (!lowest_of_9(tex, uv, sps)) {
		return false;
	}
	float local_red = texture(tex, uv).r;
	for (int i = 0; i < dirs_2.length(); i++){
		float red = get_neighbour_color(uv, sps, tex, dirs_2[i]).r;
		if (red >= local_red) {
			return false;
		}
	}
	return true;
}

bool lowest_of_49(sampler2D tex, vec2 uv, vec2 sps) {
	if (!lowest_of_25(tex, uv, sps)) {
		return false;
	}
	float local_red = texture(tex, uv).r;
	for (int i = 0; i < dirs_3.length(); i++){
		float red = get_neighbour_color(uv, sps, tex, dirs_3[i]).r;
		if (red >= local_red) {
			return false;
		}
	}
	return true;
}

void fragment() {
	vec2 uv = UV;
	vec2 sps = SCREEN_PIXEL_SIZE;
	float height = texture(TEXTURE, uv).r;
	vec3 color = vec3(0.0);
	
	if (lowest_of_49(TEXTURE, uv, sps)) {
		color = (vec3(height, 0.0, 0.0));
	}
	
	COLOR = vec4(color, 1.0);
}