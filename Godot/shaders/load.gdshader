shader_type canvas_item;

uniform sampler2D mask_tex;
uniform float scale = 1.0;
uniform float softness = 0.05;

// Pass mask texture size from GDScript (width, height)
uniform vec2 mask_tex_size = vec2(280.0, 245.0);

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 center = vec2(0.5);

    float mask_aspect = mask_tex_size.x / mask_tex_size.y;
    vec2 offset = uv - center;

    offset.x *= mask_aspect;
    offset /= (scale * vec2(1,1.5));
    offset.x /= mask_aspect;

    vec2 mask_uv = offset + center;

    // If outside mask texture UV range, set opaque black
    bool outside = (mask_uv.x < 0.0 || mask_uv.x > 1.0 || mask_uv.y < 0.0 || mask_uv.y > 1.0);

    if (outside) {
        COLOR = vec4(0.1, 0.1, 0.1, 1.0);
    } else {
        float mask_alpha = texture(mask_tex, mask_uv).a;
        float edge = smoothstep(0.0, softness, mask_alpha);
        float final_alpha = mix(1.0, 0.0, edge);
        COLOR = vec4(0.1, 0.1, 0.1, final_alpha);
    }
}