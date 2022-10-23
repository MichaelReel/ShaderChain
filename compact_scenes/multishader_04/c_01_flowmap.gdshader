shader_type canvas_item;

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

int get_compass_direction(in vec2 v) {
	float angle = atan(v.y, v.x);
	int octant = int(round(8.0 * angle / TWO_PI + 8.0)) % 8;
	return octant;
}

vec2 get_pos_from_dir(in vec2 dir) {
	return (dir + vec2(1.0)) / 2.0;
}

float height_for_pixel(vec2 uv, sampler2D tex) {
	return texture(tex, uv).r;
}

vec4 get_normal_for_pixel(vec2 uv, vec2 scs, sampler2D tex) {
	float sM = height_for_pixel(uv, tex);
	float sW = height_for_pixel(uv + dirs[4] * scs, tex);
	float sE = height_for_pixel(uv + dirs[0] * scs, tex);
	float sN = height_for_pixel(uv + dirs[2] * scs, tex);
	float sS = height_for_pixel(uv + dirs[6] * scs, tex);
	vec3 vEW = normalize(vec3(2.0, 0.0, sE - sW));
	vec3 vNS = normalize(vec3(0.0, 2.0, sS - sN));
	return vec4( cross(vEW, vNS), sM);
}

int preferred_compass_direction(vec2 uv, vec2 scs, sampler2D tex) {
	vec4 normal = get_normal_for_pixel(uv, scs, tex);
	return get_compass_direction(normalize(vec2(normal.r, -normal.g)));
}

void fragment() {
	int dir_i = preferred_compass_direction(UV, SCREEN_PIXEL_SIZE, TEXTURE);
	COLOR = vec4(get_pos_from_dir(dirs[dir_i]), 0.0, 1.0);
}