shader_type canvas_item;


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
const float CURVE_CHANCE = 0.04;
const float STRAIGHTEN_CHANCE = 0.18;

vec2 random2( vec2 p ) {
	return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

int invert_dir(int i) {
	return (i + 4) % 8;
}

vec4 get_neighbour_color(vec2 uv, vec2 sps, sampler2D tex, vec2 dir) {
	vec2 neighbour = uv + dir * sps;
	return texture(tex, neighbour);
}

int blue_nearby(vec2 uv, vec2 sps, sampler2D tex) {
	// Return a vec2 of a nearby blue, combined with it's r and g channels
	for (int i = 0; i < dirs.length(); i++){
		float blue = get_neighbour_color(uv, sps, tex, dirs[i]).b;
		if (blue >= 1.0) {
			return i;
		}
	}
	return -1;
}

int get_compass_direction(in vec2 v) {
	float angle = atan(v.y, v.x);
	int octant = int(round(8.0 * angle / TWO_PI + 8.0)) % 8;
	return octant;
}

vec2 get_dir_from_pos(in vec2 pos) {
	return pos * 2.0 - vec2(1.0);
}

vec2 get_pos_from_dir(in vec2 dir) {
	return (dir + vec2(1.0)) / 2.0;
}

int get_next_flow_dir(int i, vec2 uv) {
	// randomly change direction, but default to keeping the same direction
	float rand = fract(length(random2(uv)));
	
	// Favour curving towards the cardinal of UV
	int card = get_compass_direction(get_dir_from_pos(uv));
	int dir_diff = ((card - i) > 4) ? 
			card - i - 8 : (((card - i) < -3) ?
			card - i + 8 : card - i);
	
	if (dir_diff != 0 && rand <= STRAIGHTEN_CHANCE * float(abs(dir_diff))) {
		int diff = dir_diff / abs(dir_diff);
		return (i + diff + 8) % 8;
	}
	
	
	if (rand >= 1.0 - CURVE_CHANCE * 2.0) {
		// Rotate right
		return (i + 7) % 8;
	}
	
	if (rand >= 1.0 - CURVE_CHANCE) {
		// Rotate left
		return (i + 1) % 8;
	}
	
	// Don't curve
	return i;
}

void fragment() {
	vec3 color = texture(TEXTURE, UV).rgb;
	
	int nearby_blue = blue_nearby(UV, SCREEN_PIXEL_SIZE, TEXTURE);
	if (nearby_blue >= 0 && color.b < 0.5) {
		vec2 rg = get_neighbour_color(UV, SCREEN_PIXEL_SIZE, TEXTURE, dirs[nearby_blue]).rg;
		vec2 flow_dir = get_dir_from_pos(rg);
		int compass_dir = get_compass_direction(flow_dir);
		if (invert_dir(nearby_blue) == compass_dir){
			// Get the same, or a new compass direction
			int new_dir = get_next_flow_dir(compass_dir, UV); 
			vec2 compass_rg = get_pos_from_dir(dirs[new_dir]);
			color = vec3(compass_rg, 1.0);
		}
	}

	// Don't reuse previously existing blue points
	else if (color.b >= 0.5) {
		color.b = 0.5; //  = vec3(1.0, 1.0, 0.0);
	}

	COLOR = vec4(color,1.0);
}