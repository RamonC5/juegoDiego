shader_type canvas_item;
render_mode unshaded;

uniform int outfit = 0;
uniform vec4 scarf_color : source_color = vec4(1.0);
uniform vec4 vest_color : source_color = vec4(1.0);
uniform vec4 pants_color : source_color = vec4(1.0);

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	vec3 rgb = c.rgb;
	float light = max(max(rgb.r, rgb.g), rgb.b);
	// Máscaras también en sombra; conservar piel, pelo, gafas y camiseta.
	float warmth = (rgb.g - rgb.b) / max(rgb.r - rgb.b, 0.001);
	float scarf = smoothstep(0.44, 0.55, warmth)
		* (1.0 - smoothstep(0.22, 0.42, rgb.b / max(rgb.g, 0.001)))
		* step(rgb.g, rgb.r) * step(0.12, rgb.r);
	float vest = step(rgb.r * 1.12, rgb.g) * step(rgb.r * 1.10, rgb.b)
		* step(rgb.b * 0.98, rgb.g) * step(0.10, rgb.g);
	float shorts = step(rgb.g * 1.10, rgb.b) * step(rgb.r * 1.25, rgb.b);
	if (outfit > 0) {
		rgb = mix(rgb, scarf_color.rgb * (0.40 + light * 0.64), scarf * 0.98);
	}
	if (outfit >= 2) {
		float weave = 0.95 + 0.05 * sin((UV.x + UV.y) * 1100.0);
		rgb = mix(rgb, vest_color.rgb * (0.38 + light * 0.82) * weave, vest * 0.98);
	}
	if (outfit >= 3) {
		rgb = mix(rgb, pants_color.rgb * (0.38 + light * 0.72), shorts * 0.97);
	}
	COLOR = vec4(rgb, smoothstep(0.13, 0.40, c.a));
}

