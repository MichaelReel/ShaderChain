shader_type canvas_item;

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

float height_for_pixel(vec2 uv) {
	vec2 warp_offset = vec2(5.3, 1.3);
	float f1 = fbm(uv + warp_offset) * 0.25;
	vec2 mod_uv = uv - vec2(f1, -f1) * 0.1;
	return fbm(mod_uv);
//	return noise(mod_uv);
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
	return get_compass_direction(normalize(normal.rg));
}


void fragment() {
	vec2 uv = UV;
	
	int dir_i = preferred_compass_direction(UV, SCREEN_PIXEL_SIZE);
	
	
	
	COLOR = vec4(get_pos_from_dir(dirs[dir_i]), 0.0, 1.0);
//	COLOR = vec4(normal.a, normal.a, normal.a, 1.0);
//	COLOR = vec4(normalize(normal.rg), normal.a, 1.0);
}
