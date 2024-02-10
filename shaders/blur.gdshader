// Original by ChatGippity

shader_type canvas_item;

uniform float blur_strength : hint_range(0.0, 1.0) = 0.02;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 sum = vec4(0.0);

	for (float x = -5.0; x <= 5.0; x++) {
		for (float y = -5.0; y <= 5.0; y++) {
			sum += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(x, y) * blur_strength);
		}
	}

	COLOR = sum / 121.0; // 121 is the number of samples (11x11)
}