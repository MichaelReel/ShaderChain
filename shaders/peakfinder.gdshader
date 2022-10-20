shader_type canvas_item;

uniform vec2 Mouse;
uniform float min_intensity;
uniform float max_intensity;
uniform float max_edge;

vec3 lerp_vec3(in vec3 v1, in vec3 v2, in float t) {
	return v1 + t * (v2 - v1);
}

float inv_lerp_float(in float a, in float b, in float v) {
    return (v - a) / (b - a);
}

vec2 screen_pos(in vec2 fragcoord, in vec2 spsize) {
    return fragcoord/(1.0/spsize);
}

void fragment() {
	vec2 st = screen_pos(FRAGCOORD.xy, SCREEN_PIXEL_SIZE);
	vec3 color = texture(TEXTURE, UV.xy).rgb;

	color.g = inv_lerp_float(min_intensity, max_intensity, color.g);

	color = lerp_vec3(vec3(1.0, color.g, 0.0), vec3(0.0, color.g, 1.0), step(0.5, color.g));
	
	COLOR = vec4(color, 1.0);
}
