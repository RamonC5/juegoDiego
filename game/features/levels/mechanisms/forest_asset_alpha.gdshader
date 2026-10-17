shader_type canvas_item;
render_mode unshaded;

varying vec4 vertex_tint;

void vertex() {
	vertex_tint = COLOR;
}

void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	pixel.a = smoothstep(0.13, 0.40, pixel.a);
	COLOR = pixel * vertex_tint;
}
