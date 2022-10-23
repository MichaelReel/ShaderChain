shader_type canvas_item;


uniform sampler2D height_map;

const vec2 dirs[] = {
	vec2( 1.0,  0.0),  // E
	vec2( 1.0,  1.0),  // NE
	vec2( 0.0,  1.0),  // N
	vec2(-1.0,  1.0),  // NW
	vec2(-1.0,  0.0),  // W
	vec2(-1.0, -1.0),  // SW
	vec2( 0.0, -1.0),  // S
	vec2( 1.0, -1.0)   // SE
};


vec4 get_neighbour_color(vec2 uv, vec2 sps, sampler2D tex, int dir_i) {
	vec2 neighbour = uv + dirs[dir_i] * sps;
	return texture(tex, neighbour);
}

bool lowest_of_nine(sampler2D tex, vec2 uv, vec2 sps) {
	float local_red = texture(height_map, uv).r;
	for (int i = 0; i < dirs.length(); i++){
		float red = get_neighbour_color(uv, sps, tex, i).r;
		if (red > local_red) {
			return false;
		}
	}
	return true;
}

void fragment() {
	vec2 uv = UV;
	vec3 color = vec3(0.0); // texture(height_map, uv).rgb;
	
	
	if (lowest_of_nine(height_map, uv, SCREEN_PIXEL_SIZE)) {
		color.b = 1.0;
	}
	
	COLOR = vec4(color, 1.0);
}