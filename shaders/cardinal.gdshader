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
	
	vec2 from_center = get_dir_from_pos(UV);
	vec2 compass_dir = get_compass_direction(from_center);
	vec2 uv = get_pos_from_dir(compass_dir);
	
	COLOR = vec4(uv, 0.5, 1.0);
}
