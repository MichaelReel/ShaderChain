shader_type canvas_item;

uniform float A = 1.0;
//
const float DEPTH = 0.5;
const float X_MORPH = 0.75;

const float K1 = 0.366025404; // (sqrt(3)-1)/2;
const float K2 = 0.211324865; // (3-sqrt(3))/6;
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

vec2 hash( vec2 p )
{
	p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
	return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise( in vec2 p )
{
	vec2  i = floor(p + (p.x + p.y) * K1);
	vec2  a = p - i + (i.x + i.y) * K2;
	float m = step(a.y, a.x); 
	vec2  o = vec2(m, 1.0 - m);
	vec2  b = a - o + K2;
	vec2  c = a - 1.0 + 2.0 * K2;
	vec3  h = max(0.5 - vec3(dot(a, a), dot(b, b), dot(c, c)), 0.0);
	vec3  n = h * h * h * h * vec3(dot(a, hash(i+0.0)), dot(b, hash(i+o)), dot(c, hash(i+1.0)));
	return dot(n, vec3(70.0));
}

float fbm(vec2 uv) {
	uv *= 5.0;
	mat2 m = mat2(vec2(1.6,  1.2), vec2(-1.2,  1.6));
	
	float f = 0.0;
	f  = 0.5000 * noise(uv);
	uv = m * uv;
	f += 0.2500 * noise(uv);
	uv = m * uv;
	f += 0.1250 * noise(uv);
	uv = m * uv;
	f += 0.0625 * noise(uv);
	uv = m * uv;
	
	f = 0.5 + 0.5 * f;
	
	// Re-level the noise to be more 0.0 to 1.0
	f = smoothstep(0.2, 0.7, f);
	
	return f;
}

float noise_height_for_pixel(vec2 uv) {
	vec2 warp_offset = vec2(5.3, 1.3);
	float f1 = fbm(uv + warp_offset) * 0.25;
	vec2 mod_uv = uv - vec2(f1, -f1) * 0.1;
	return fbm(mod_uv);
}

float height_for_pixel(vec2 uv) {
	float noise =  noise_height_for_pixel(uv);
	
	// Circular, around the middle
	float cf = clamp((1.0 - DEPTH) - distance(uv, vec2(0.5)), 0.0, 1.0);

	// Find the nearest edges
	float vert = step(0.5, uv.y);
	float hort = step(0.5, uv.x);
	float sf = min(abs(vert - uv.y), abs(hort - uv.x)) + 0.5 - DEPTH;

	float f = mix(cf, sf, X_MORPH);
	return (noise * f + f);
}

vec4 get_normal_for_pixel(vec2 uv, vec2 scs) {
	float sM = height_for_pixel(uv);
	float sW = height_for_pixel(uv + dirs[4] * scs);
	float sE = height_for_pixel(uv + dirs[0] * scs);
	float sN = height_for_pixel(uv + dirs[2] * scs);
	float sS = height_for_pixel(uv + dirs[6] * scs);
	vec3 vEW = normalize(vec3(2.0, 0.0, sE - sW));
	vec3 vNS = normalize(vec3(0.0, 2.0, sS - sN));
	return vec4( cross(vEW, vNS), sM);
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

int preferred_compass_direction(vec2 uv, vec2 scs) {
	vec4 normal = get_normal_for_pixel(uv, scs);
	return get_compass_direction(normalize(vec2(normal.r, -normal.g)));
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

int get_flow_ecouragement(int dir_i, vec2 uv, vec2 sps) {
	// Encourage the flow to curve with the underlying noise
	int card = preferred_compass_direction(uv, sps);
	int simple_diff = card - dir_i;
	// 4 and -4 are basically equivalent, but that's probably okay ¯\_(ツ)_/¯
	if (simple_diff > 4) return simple_diff - 8;
	if (simple_diff < -4) return simple_diff + 8;
	return simple_diff;
}

int get_next_flow_dir(int i, vec2 uv, vec2 scs) {
	// Favour curving towards the cardinal of UV
	int dir_diff = get_flow_ecouragement(i, uv, scs);
	
	if (dir_diff != 0) {
		int diff = dir_diff / abs(dir_diff);
		return (i + diff + 8) % 8;
	}
	
	// Don't curve
	return i;
}


void fragment() {
//	int dir_i = preferred_compass_direction(UV, SCREEN_PIXEL_SIZE);
//	COLOR = vec4(get_pos_from_dir(dirs[dir_i]), 0.0, 1.0);
	
	vec3 color = texture(TEXTURE, UV).rgb;

	int nearby_blue = blue_nearby(UV, SCREEN_PIXEL_SIZE, TEXTURE);
	if (nearby_blue >= 0 && color.b < 0.5) {
		vec2 rg = get_neighbour_color(UV, SCREEN_PIXEL_SIZE, TEXTURE, dirs[nearby_blue]).rg;
		vec2 flow_dir = get_dir_from_pos(rg);
		int compass_dir = get_compass_direction(flow_dir);
		if (invert_dir(nearby_blue) == compass_dir){
			// Get the same, or a new compass direction
			int new_dir = get_next_flow_dir(compass_dir, UV, SCREEN_PIXEL_SIZE); 
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
