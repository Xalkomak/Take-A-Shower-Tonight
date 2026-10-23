shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

uniform float soap_amount : hint_range(0.0, 1.0) = 0.0;
uniform float blur_strength : hint_range(0.0, 15.0) = 4.0;
uniform float noise_scale : hint_range(1.0, 30.0) = 8.0;

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x)
         + (c - a) * u.y * (1.0 - u.x)
         + (d - b) * u.x * u.y;
}

void fragment() {
    vec2 uv = SCREEN_UV;

    // Distance from screen center.
    float vignette = distance(uv, vec2(0.5));
    vignette = smoothstep(0.15, 0.75, vignette);

    // Procedural lather.
    float n = noise(uv * noise_scale);
    n = smoothstep(0.35, 0.7, n);

    float lather = n * vignette * soap_amount;

    // Multi-sample blur.
    vec2 texel = SCREEN_PIXEL_SIZE * blur_strength;

    vec4 color = vec4(0.0);

    color += texture(screen_texture, uv + vec2(-texel.x, 0.0));
    color += texture(screen_texture, uv + vec2(texel.x, 0.0));
    color += texture(screen_texture, uv + vec2(0.0, -texel.y));
    color += texture(screen_texture, uv + vec2(0.0, texel.y));
    color += texture(screen_texture, uv);

    color /= 5.0;

    // Mix blurred vision according to soap coverage.
    color.rgb = mix(texture(screen_texture, uv).rgb, color.rgb, soap_amount);

    // White translucent lather.
    color.rgb = mix(color.rgb, vec3(1.0), lather * 0.75);

    COLOR = color;
}