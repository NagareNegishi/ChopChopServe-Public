shader_type canvas_item;

uniform float blur_radius : hint_range(0.0, 10.0, 0.1) = 2.0;
uniform int blur_samples : hint_range(1, 10) = 3;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 pixel_size = blur_radius * SCREEN_PIXEL_SIZE;
    vec4 sum = vec4(0.0);
    int count = 0;

    for (int x = -blur_samples; x <= blur_samples; x++) {
        for (int y = -blur_samples; y <= blur_samples; y++) {
            sum += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(float(x), float(y)) * pixel_size);
            count++;
        }
    }

    COLOR = sum / float(count);
}