shader_type canvas_item;

uniform float min_intensity;
uniform float max_intensity;

vec2 screen_pos(in vec2 fragcoord, in vec2 spsize) {
    return fragcoord/(1.0/spsize);
}

void fragment() {
	vec2 st = screen_pos(FRAGCOORD.xy, SCREEN_PIXEL_SIZE);
	vec3 color = texture(TEXTURE, UV.xy).rgb;

	color = smoothstep(min_intensity, max_intensity, color);

	COLOR = vec4(color, 1.0);
}
