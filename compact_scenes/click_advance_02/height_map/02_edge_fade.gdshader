shader_type canvas_item;


uniform float x_shape = 0.5;
uniform float depth = 0.5;


float get_edge_fade(vec2 uv) {
	// Circular, around the middle
	float cf = clamp((1.0 - depth) - distance(uv, vec2(0.5)), 0.0, 1.0);

	// Find the nearest edges
	float vert = step(0.5, uv.y);
	float hort = step(0.5, uv.x);
	float sf = min(abs(vert - uv.y), abs(hort - uv.x)) + 0.5 - depth;

	float f = mix(cf, sf, x_shape);

	return f;
}


void fragment() {
	vec2 uv = UV;
	vec3 color = texture(TEXTURE, uv).rgb;
	
	float f = get_edge_fade(uv);

	vec3 fade = vec3(f);

	color = (color * fade + fade);
		
	COLOR = vec4(color, 1.0);
}
