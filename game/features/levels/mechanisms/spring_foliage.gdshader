shader_type canvas_item;
render_mode unshaded;

// Recorte orgánico del atlas: copa y tallo, sin el rectángulo de hojas vecino.
void fragment() {
	vec4 sample_color = texture(TEXTURE, UV);
	vec2 local_uv = (UV - vec2(0.79, 0.373)) / vec2(0.125);
	float cap = 1.0 - smoothstep(0.87, 1.0,
		length((local_uv - vec2(0.43, 0.29)) / vec2(0.46, 0.25)));
	float stem = 1.0 - smoothstep(0.83, 1.0,
		length((local_uv - vec2(0.48, 0.70)) / vec2(0.18, 0.30)));
	sample_color.a = smoothstep(0.13, 0.40, sample_color.a) * max(cap, stem);
	COLOR = sample_color;
}
