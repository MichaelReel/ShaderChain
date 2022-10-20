shader_type canvas_item;
uniform vec2 Mouse;

vec2 square_pos(in vec2 fragcoord, in vec2 spsize, in float ratio) {
    vec2 res = 1.0/spsize;
    vec2 st = fragcoord/res;
    st.x *= res.x/res.y * ratio;
    return st;
}

float lerp_float(in float a, in float b, in float t) {
	return a + t * (b - a);
}

void fragment() {
	vec2 st = square_pos(FRAGCOORD.xy, SCREEN_PIXEL_SIZE, 1.0);
	vec3 color = texture(TEXTURE, UV.xy).rgb;
	
	// Circular, around the middle
	float cf = clamp((1.0 - Mouse.x) - distance(st, vec2(0.5)), 0.0, 1.0);

	// Find the nearest edges
	float vert = step(0.5, st.y);
	float hort = step(0.5, st.x);
	float sf = min(abs(vert - st.y), abs(hort - st.x)) + 0.5 - Mouse.x;

	float f = lerp_float(cf, sf, Mouse.y);
	
	vec3 fade = vec3(f);
	
	color *= fade;
		
	COLOR = vec4(color, 1.0);
}
