shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_back;

// Water color
uniform vec4 out_color    : source_color                   = vec4(0.0, 0.2, 1.0, 1.0);
// Amount of height for each triangle
uniform float amount      : hint_range(0.2, 5.0, 0.1)      = 0.8;
// Speed of the triangles’ height change
uniform float speed       : hint_range(0.1, 5.0, 0.1)      = 1.0;
// Beer-Lambert absorption factor (controls transparency)
uniform float beer_factor                               = 0.2;
// PBR surface parameters
uniform float metallic    : hint_range(0.0, 1.0)         = 0.6;
uniform float specular    : hint_range(0.0, 1.0)         = 0.5;
uniform float roughness   : hint_range(0.0, 1.0)         = 0.2;

// Depth buffer (you must enable “Depth Texture” on the viewport)
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

float generate_offset(float x, float z, float v1, float v2, float t) {
    float rad_x = ((mod(x + z*x*v1, amount) / amount)
                 + (t * speed) * mod(x*0.8 + z, 1.5))
                * 2.0 * PI;
    float rad_z = ((mod(v2 * (z*x + x*z), amount) / amount)
                 + (t * speed) * 2.0 * mod(x, 2.0))
                * 2.0 * PI;
    return amount * 0.5 * (sin(rad_z) * cos(rad_x));
}

vec3 apply_distortion(vec3 v, float t) {
    float xd = generate_offset(v.x, v.z, 0.2, 0.1, t);
    float yd = generate_offset(v.x, v.z, 0.1, 0.3, t);
    float zd = generate_offset(v.x, v.z, 0.15, 0.2, t);
    return v + vec3(xd, yd, zd);
}

void vertex() {
    // Distort in local space
    VERTEX = apply_distortion(VERTEX, TIME * 0.1);
}

void fragment() {
    // Recompute normal from distorted geometry
    NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));

    // Base material parameters
    ALBEDO    = out_color.rgb;
	EMISSION = out_color.rgb * 0.7; // Boosts brightness without overpowering
    METALLIC  = metallic;
    SPECULAR  = specular;
    ROUGHNESS = roughness;

    if (beer_factor > 0.0) {
        // Sample screen-space depth
        float d = texture(depth_texture, SCREEN_UV).r;
        // Linearize from [0,1] to NDC then to view-space Z
        d = d * 2.0 - 1.0;
        float view_z = PROJECTION_MATRIX[3][2]
                     / max(d + PROJECTION_MATRIX[2][2], 0.001);
        // Beer-Lambert absorption
        float absorption = exp(-view_z * beer_factor);
        ALPHA = 0.9;
    } else {
        ALPHA = out_color.a;
    }
}
