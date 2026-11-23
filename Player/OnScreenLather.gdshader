shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform sampler2D bubble_texture : repeat_enable, filter_linear;

uniform float bubble_scroll : hint_range(-2.0, 2.0) = 0.0;
uniform float bubble_opacity : hint_range(0.0, 1.0) = 0.5;
uniform float bubble_scale : hint_range(0.1, 5.0) = 1.0;
uniform float soap_amount : hint_range(0.0, 1.0) = 0.0;
uniform float lather_rotation : hint_range(0.0, 6.28318) = 0.0;
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
    // Rotate procedural lather coordinates around screen center.
	vec2 centered_uv = uv - vec2(0.5);

	float c = cos(lather_rotation);
	float s = sin(lather_rotation);

	mat2 rotation = mat2(
    	vec2(c, -s),
    	vec2(s, c)
	);

	vec2 rotated_uv = rotation * centered_uv + vec2(0.5);

	float n = noise(rotated_uv * noise_scale);
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
	
	// Bubble texture UVs.
	vec2 bubble_uv = SCREEN_UV;

	// Correct for the screen's aspect ratio.
	bubble_uv.x *= SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;

	// Scale the pattern.
	bubble_uv *= bubble_scale;

	// Vertical scrolling, independent of lather rotation.
	bubble_uv.y += bubble_scroll;

	// Sample bubbles.
	vec4 bubbles = texture(bubble_texture, bubble_uv);

	// Overlay bubbles.
	float bubble_alpha = bubbles.a * bubble_opacity * soap_amount;

	color.rgb = mix(color.rgb, bubbles.rgb, bubble_alpha);

    COLOR = color;
}