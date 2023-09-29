// Original by ChatGippity

shader_type canvas_item;

uniform float blur_strength : hint_range(0.0, 1.0) = 0.02;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec4 sum = vec4(0.0);

    for (int x = -5; x <= 5; x++) {
        for (int y = -5; y <= 5; y++) {
            sum += textureLod(SCREEN_TEXTURE, SCREEN_UV + vec2(float(x), float(y)) * blur_strength, 0.0);
        }
    }

    COLOR = sum / 121.0; // 121 is the number of samples (11x11)
}