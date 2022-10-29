shader_type canvas_item;

uniform float slice_height = 0.15;

void fragment() {
	float height = texture(TEXTURE, UV).r;
	
	vec3 color = vec3(step(slice_height, height));
	COLOR = vec4(color, 1.0);
}