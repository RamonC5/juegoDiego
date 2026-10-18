shader_type canvas_item;
render_mode unshaded;

uniform int outfit = 0;
uniform sampler2D fern_fabric : source_color, repeat_enable, filter_linear;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	vec3 rgb = c.rgb;
	float light = max(max(rgb.r, rgb.g), rgb.b);
	// Máscaras de material sobre el raster: conservan piel, gafas, pelo y poses.
	float scarf = step(rgb.g * 1.11, rgb.r) * step(rgb.b * 1.8, rgb.g)
		* step(0.40, rgb.g) * step(0.70, rgb.r);
	float vest = step(rgb.r * 1.23, rgb.g) * step(rgb.b * 0.88, rgb.g)
		* step(rgb.r * 1.25, rgb.b) * step(0.16, rgb.g);
	float shorts = step(rgb.g * 1.13, rgb.b) * step(rgb.r * 1.35, rgb.b);
	if (outfit > 0) {
		vec3 scarf_tint = outfit == 1 ? vec3(0.83, 0.18, 0.15) : vec3(0.93, 0.70, 0.24);
		if (outfit == 3) { scarf_tint = vec3(0.67, 0.87, 0.32); }
		if (outfit == 4) { scarf_tint = vec3(0.96, 0.84, 0.47); }
		rgb = mix(rgb, scarf_tint * light, scarf * 0.94);
	}
	if (outfit >= 2) {
		vec3 fabric = texture(fern_fabric, UV * 5.0).rgb;
		vec3 tint = outfit == 4 ? vec3(0.91, 0.69, 0.28) : vec3(0.36, 0.72, 0.28);
		rgb = mix(rgb, tint * light * (0.75 + fabric.g * 0.9), vest * 0.92);
	}
	if (outfit >= 3) {
		rgb = mix(rgb, vec3(0.56, 0.43, 0.24) * light, shorts * 0.88);
	}
	COLOR = vec4(rgb, smoothstep(0.13, 0.40, c.a));
}
