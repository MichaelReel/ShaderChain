shader_type canvas_item;



void fragment() {
	vec3 color = texture(TEXTURE, UV).rgb;
	
	color.g = floor(color.g * 10.0) / 10.0;
//	color.g = color.r;
	color.b = 1.0 - step(0.1, color.b);
	
	COLOR = vec4(color, 1.0);
}
