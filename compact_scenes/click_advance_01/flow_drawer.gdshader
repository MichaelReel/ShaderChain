shader_type canvas_item;


uniform sampler2D flow_map;

const float TWO_PI = 6.28318530719586;
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

int invert_dir(int i) {
	return (i + 4) % 8;
}

vec2 get_dir_from_pos(in vec2 pos) {
	return pos * 2.0 - vec2(1.0);
}

vec2 get_pos_from_dir(in vec2 dir) {
	return (dir + vec2(1.0)) / 2.0;
}

int get_compass_direction(in vec2 v) {
	float angle = atan(v.y, v.x);
	int octant = int(round(8.0 * angle / TWO_PI + 8.0)) % 8;
	return octant;
}

vec4 get_neighbour_color(vec2 uv, vec2 sps, sampler2D tex, int dir_i) {
	vec2 neighbour = uv + dirs[dir_i] * sps;
	return texture(tex, neighbour);
}

int blue_nearby(vec2 uv, vec2 sps, sampler2D tex) {
	// Return a vec2 of a nearby blue, combined with it's r and g channels
	for (int i = 0; i < dirs.length(); i++){
		float blue = get_neighbour_color(uv, sps, tex, i).b;
		if (blue >= 1.0) {
			return i;
		}
	}
	return -1;
}

int preferred_compass_direction(vec2 uv, sampler2D flow_tex) {
	vec4 normal = texture(flow_tex, uv);
	return get_compass_direction(get_dir_from_pos(normal.rg));
}

int get_flow_ecouragement(int dir_i, vec2 uv, sampler2D flow_tex) {
	// Encourage the flow to curve with the underlying noise
	int card = preferred_compass_direction(uv, flow_tex);
	int simple_diff = card - dir_i;
	// 4 and -4 are basically equivalent, but that's probably okay ¯\_(ツ)_/¯
	if (simple_diff > 4) return simple_diff - 8;
	if (simple_diff < -4) return simple_diff + 8;
	return simple_diff;
}

int get_next_flow_dir(int i, vec2 uv, sampler2D flow_tex) {
	// Favour curving towards the cardinal of UV
	int dir_diff = get_flow_ecouragement(i, uv, flow_tex);
	
	if (dir_diff != 0) {
		int diff = dir_diff / abs(dir_diff);
		return (i + diff + 8) % 8;
	}
	
	// Don't curve
	return i;
}

vec4 get_flow_into_this_pixel(sampler2D worley_map, sampler2D flows, vec2 uv, vec2 scs) {
	vec4 worley_color = texture(worley_map, uv);
	vec4 flow_color = texture(flows, uv);

	int nearby_blue = blue_nearby(uv, scs, worley_map);
	if (nearby_blue >= 0 && worley_color.b < 0.5) {
		vec2 rg = get_neighbour_color(uv, scs, worley_map, nearby_blue).rg;
		vec2 flow_dir = get_dir_from_pos(rg);
		int compass_dir = get_compass_direction(flow_dir);
		if (invert_dir(nearby_blue) == compass_dir){
			
//			// Set the new compass direction by curving on the flow map
//			int new_dir = get_next_flow_dir(compass_dir, uv, flows);
//			vec2 compass_rg = get_pos_from_dir(dirs[new_dir]);
			
			vec2 compass_rg = mix(rg, flow_color.rg, 0.5);
			worley_color = vec4(compass_rg, 1.0, 1.0);
		}
	}
	return worley_color;
}


void fragment() {
	vec2 uv = UV;
	
	vec4 worley_color = get_flow_into_this_pixel(TEXTURE, flow_map, UV, SCREEN_PIXEL_SIZE);
	
	COLOR = worley_color;
}