shader_type spatial;
render_mode unshaded;

uniform sampler2D height_map;
uniform float height_scale = 0.4;

void vertex() {
	float height = texture(height_map, VERTEX.xz).r;
	VERTEX.y += height * height_scale;
}

void fragment() {
	vec3 color = texture(height_map, UV).rgb;
	ALBEDO = color;
}