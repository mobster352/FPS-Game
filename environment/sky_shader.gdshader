shader_type canvas_item;

uniform float cloud_coverage : hint_range(0.0, 1.0) = 0.55;
uniform float cloud_softness : hint_range(0.01, 0.5) = 0.22;
uniform float cloud_scale : hint_range(0.5, 12.0) = 3.0;
uniform float cloud_speed : hint_range(0.0, 1.0) = 0.025;
uniform float cloud_brightness : hint_range(0.0, 1.5) = 0.85;

uniform vec3 sky_horizon_color = vec3(0.72, 0.88, 1.0);
uniform vec3 sky_mid_color = vec3(0.38, 0.68, 1.0);
uniform vec3 sky_top_color = vec3(0.18, 0.48, 0.95);

uniform vec3 sun_direction = vec3(0.35, 0.45, 0.25);
uniform vec3 sun_color = vec3(1.0, 0.86, 0.55);
uniform float sun_size : hint_range(0.001, 0.2) = 0.035;
uniform float sun_glow_size : hint_range(0.01, 0.6) = 0.22;
uniform float sun_intensity : hint_range(0.0, 5.0) = 1.4;

uniform vec3 moon_direction = vec3(-0.35, -0.45, -0.25);
uniform vec3 moon_color = vec3(0.72, 0.78, 1.0);
uniform float moon_size : hint_range(0.001, 0.2) = 0.028;
uniform float moon_glow_size : hint_range(0.01, 0.6) = 0.18;
uniform float moon_intensity : hint_range(0.0, 3.0) = 0.8;

float hash(vec3 p) {
	p = fract(p * 0.3183099 + vec3(0.1, 0.2, 0.3));
	p *= 17.0;
	return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float noise(vec3 p) {
	vec3 i = floor(p);
	vec3 f = fract(p);
	f = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);

	float n000 = hash(i + vec3(0,0,0));
	float n100 = hash(i + vec3(1,0,0));
	float n010 = hash(i + vec3(0,1,0));
	float n110 = hash(i + vec3(1,1,0));
	float n001 = hash(i + vec3(0,0,1));
	float n101 = hash(i + vec3(1,0,1));
	float n011 = hash(i + vec3(0,1,1));
	float n111 = hash(i + vec3(1,1,1));

	return mix(
		mix(mix(n000, n100, f.x), mix(n010, n110, f.x), f.y),
		mix(mix(n001, n101, f.x), mix(n011, n111, f.x), f.y),
		f.z
	);
}

float fbm(vec3 p) {
	float value = 0.0;
	float amplitude = 0.5;

	for (int i = 0; i < 6; i++) {
		value += noise(p) * amplitude;
		p *= 2.05;
		amplitude *= 0.5;
	}

	return value;
}

void fragment() {
	float theta = UV.y * PI;
	float phi = UV.x * TAU;

	vec3 dir;
	dir.x = sin(phi) * sin(theta);
	dir.y = cos(theta);
	dir.z = cos(phi) * sin(theta);
	dir = normalize(dir);

	// Natural blue sky gradient
	float height = clamp(dir.y * 0.5 + 0.5, 0.0, 1.0);

	//vec3 horizon_color = vec3(0.72, 0.88, 1.0);
	//vec3 horizon_color = vec3(0.18, 0.18, 0.35);
	//vec3 mid_color = vec3(0.38, 0.68, 1.0);
	//vec3 mid_color = vec3(0.18, 0.18, 0.35);
	//vec3 top_color = vec3(0.18, 0.48, 0.95);
	//vec3 top_color = vec3(0.18, 0.18, 0.35);

	vec3 sky_color = mix(sky_horizon_color, sky_mid_color, smoothstep(0.0, 0.55, height));
	sky_color = mix(sky_color, sky_top_color, smoothstep(0.45, 1.0, height));

	// 3D cloud noise, so it does not pinch at the poles
	vec3 wind = vec3(TIME * cloud_speed, 0.0, TIME * cloud_speed * 0.45);
	vec3 cloud_pos = dir * cloud_scale + wind;

	float base = fbm(cloud_pos);
	float detail = fbm(cloud_pos * 3.0 + vec3(8.0, 2.0, 4.0));

	float cloud_shape = base * 0.75 + detail * 0.25;

	// Softer cloud threshold
	float threshold = mix(0.75, 0.35, cloud_coverage);
	float clouds = smoothstep(
		threshold,
		threshold + cloud_softness,
		cloud_shape
	);

	// Keep clouds mostly away from the exact top/bottom poles
	float pole_fade = smoothstep(0.02, 0.35, 1.0 - abs(dir.y));
	clouds *= pole_fade;

	// Keep clouds more visible near horizon/mid-sky
	float horizon_clouds = smoothstep(0.05, 0.8, 1.0 - abs(dir.y));
	clouds *= horizon_clouds;

	// Add softer cloud edges
	float wisps = smoothstep(threshold - 0.18, threshold + 0.18, cloud_shape);
	clouds = mix(wisps * 0.35, clouds, clouds);

	vec3 cloud_color = vec3(1.0, 0.98, 0.94);
	vec3 shaded_cloud = mix(vec3(0.78, 0.86, 0.92), cloud_color, cloud_shape);
	shaded_cloud *= cloud_brightness;

	// Sun
	vec3 sun_dir = normalize(sun_direction);
	float sun_dot = max(dot(dir, sun_dir), 0.0);

	// Hard sun disk
	float sun_disk = smoothstep(
		sun_size,
		sun_size * 0.45,
		acos(clamp(sun_dot, -1.0, 1.0))
	);

	// Soft glow around the sun
	float sun_glow = pow(sun_dot, 1.0 / sun_glow_size);

	// Clouds should partially cover the sun
	float sun_visibility = 1.0 - clouds * 0.65;

	vec3 sun = sun_color * sun_intensity * sun_visibility;
	sky_color += sun * sun_glow * 0.45;
	sky_color += sun * sun_disk;
	
	// Moon
	vec3 moon_dir = normalize(moon_direction);
	float moon_dot = max(dot(dir, moon_dir), 0.0);

	// Moon disk
	float moon_disk = smoothstep(
		moon_size,
		moon_size * 0.45,
		acos(clamp(moon_dot, -1.0, 1.0))
	);

	// Soft moon glow
	float moon_glow = pow(moon_dot, 1.0 / moon_glow_size);

	// Clouds partially cover the moon
	float moon_visibility = 1.0 - clouds * 0.75;

	vec3 moon = moon_color * moon_intensity * moon_visibility;
	sky_color += moon * moon_glow * 0.25;
	sky_color += moon * moon_disk;

	vec3 final_color = mix(sky_color, shaded_cloud, clouds * 0.75);

	COLOR = vec4(final_color, 1.0);
}