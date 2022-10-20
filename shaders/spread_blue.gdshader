shader_type canvas_item;

// This shader tried to find points that designated to move in a certain 
// direction because of the initial red and green channels
// uses the blue channel to indicate pixels to visit and pixels visited


const float TWO_PI = 6.28318530719586;
const vec2 dirs[] = {
	vec2( 1.0,  0.0),
	vec2( 1.0,  1.0),
	vec2( 0.0,  1.0),
	vec2(-1.0,  1.0),
	vec2(-1.0,  0.0),
	vec2(-1.0, -1.0),
	vec2( 0.0, -1.0),
	vec2( 1.0, -1.0)
};

vec4 get_neighbour_color(vec2 uv, vec2 sps, sampler2D tex, vec2 dir) {
	vec2 neighbour = uv + dir * sps;
	return texture(tex, neighbour);
}

vec2 blue_nearby(vec2 uv, vec2 sps, sampler2D tex) {
	// Return a vec2 of a nearby blue, combined with it's r and g channels
	for (int i = 0; i < dirs.length(); i++){
		float blue = get_neighbour_color(uv, sps, tex, dirs[i]).b;
		if (blue >= 1.0) {
			return dirs[i];
		}
	}
	return vec2(0.0);
}

vec2 get_compass_direction(in vec2 v) {
	float angle = atan(v.y, v.x);
	int octant = int(round(8.0 * angle / TWO_PI + 8.0)) % 8;
	return dirs[octant];
}

vec2 get_dir_from_pos(in vec2 pos) {
	return pos * 2.0 - vec2(1.0);
}

vec2 get_pos_from_dir(in vec2 dir) {
	return (dir + vec2(1.0)) / 2.0;
}

void fragment() {
	vec3 color = texture(TEXTURE, UV).rgb;
	
	vec2 nearby_blue = blue_nearby(UV, SCREEN_PIXEL_SIZE, TEXTURE);
	if (nearby_blue != vec2(0.0) && color.b < 0.5) {
		vec2 rg = get_neighbour_color(UV, SCREEN_PIXEL_SIZE, TEXTURE, nearby_blue).rg;
		vec2 flow_dir = get_dir_from_pos(rg);
		vec2 compass_dir = get_compass_direction(flow_dir);
		vec2 compass_rg = get_pos_from_dir(compass_dir);
		if (-nearby_blue == compass_dir){
			color = vec3(compass_rg, 1.0);
		}
	}

	// Don't reuse previously existing blue points
	else if (color.b >= 0.5) {
		color.b = 0.5; //  = vec3(1.0, 1.0, 0.0);
	}

	COLOR = vec4(color,1.0);
}