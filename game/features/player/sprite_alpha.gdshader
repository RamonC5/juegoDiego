shader_type canvas_item;
render_mode unshaded;

// Descarta el alfa residual de las hojas generadas, conservando borde suave.
void fragment() {
	vec4 sample_color = texture(TEXTURE, UV);
	sample_color.a = smoothstep(0.13, 0.40, sample_color.a);
	COLOR = sample_color;
}
