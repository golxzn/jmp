shader_type canvas_item;

#define CENTERED(value) (2.0 * value - 1.0)

uniform vec3 effect_color : source_color = vec3(0.2, 0.3, 0.8);
uniform int octave_count : hint_range(1, 20) = 10;
uniform float speed = 0.5;
uniform float initial_amplitude = 0.5;
uniform float gain = 0.5;
uniform float frequency = 2.0;
uniform float min_lighting_width : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float max_lighting_width : hint_range(0.0, 1.0, 0.01) = 0.05;
uniform float alpha_cut_off : hint_range(0.0, 1.0, 0.1) = 0.4;

float hash12(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5453);
}

vec2 hash22(vec2 uv) {
    uv = vec2(dot(uv, vec2(127.1,311.7)),
              dot(uv, vec2(269.5,183.3)));
    return 2.0 * fract(sin(uv) * 43758.5453123) - 1.0;
}

float noise(vec2 uv) {
    vec2 iuv = floor(uv);
    vec2 fuv = fract(uv);
    vec2 blur = smoothstep(0.0, 1.0, fuv);
    return mix(mix(dot(hash22(iuv + vec2(0.0,0.0)), fuv - vec2(0.0,0.0)),
                   dot(hash22(iuv + vec2(1.0,0.0)), fuv - vec2(1.0,0.0)), blur.x),
               mix(dot(hash22(iuv + vec2(0.0,1.0)), fuv - vec2(0.0,1.0)),
                   dot(hash22(iuv + vec2(1.0,1.0)), fuv - vec2(1.0,1.0)), blur.x), blur.y) + 0.5;
}

float fbm(vec2 uv, int octaves, float freq, float amp_gain) {
	float value = 0.0;
	float amplitude = initial_amplitude;

	while (octaves >= 0) {
		value += amplitude * noise(uv);
		uv *= freq;
		amplitude *= amp_gain;
		--octaves;
	}

	return value;
}

float when_gt(float x, float y) {
	return max(sign(x - y), 0.0);
}

float circle(vec2 position, float radius, float feather) {
	return smoothstep(radius, radius + feather, length(position - vec2(0.5)));
}

bool in_range(float x, float b, float e) {
	return x >= b && x <= e;
}

float smooth_border(vec2 uv, float border_start, float border_width) {
	vec2 bottom_left = smoothstep(vec2(border_start), vec2(border_width), uv);
	vec2 top_right = smoothstep(vec2(border_start), vec2(border_width), 1.0 - uv);
	return bottom_left.x * bottom_left.y * top_right.x * top_right.y;
}

void fragment() {
	float time = TIME * speed;

	vec2 uv = CENTERED(UV);
	uv += CENTERED(fbm(uv + time, octave_count, frequency, gain));
	float light_width = mix(min_lighting_width, max_lighting_width, hash12(vec2(time)));
	vec3 color = effect_color * light_width / abs(uv.x + uv.y);
	float alpha = smooth_border(UV, 0.05, 0.2)
				* when_gt((color.r + color.g + color.b) / 3.0, alpha_cut_off);

	COLOR = vec4(color, alpha);
}
