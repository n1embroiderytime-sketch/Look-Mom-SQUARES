shader_type canvas_item;

uniform vec4 grid_color : source_color = vec4(1.0, 1.0, 1.0, 0.08);
uniform float cell_size = 40.0;
uniform float line_width = 1.0;
uniform float warp_strength = 0.015;
uniform vec2 warp_center = vec2(0.5, 0.65);

uniform vec2 touch_center = vec2(0.5, 0.5);
uniform float touch_intensity = 0.0;
uniform float touch_size = 0.05;

void fragment() {
    vec2 uv = UV;
    vec2 diff = uv - warp_center;
    float d = length(diff);
    float influence = smoothstep(0.45, 0.0, d);
    uv -= normalize(diff + vec2(0.0001)) * influence * warp_strength;

    float cell_scale = 1.0 / max(cell_size / 1024.0, 0.0001);
    vec2 grid = abs(fract(uv * cell_scale) - 0.5);
    float gx = smoothstep(0.5, 0.5 - line_width * 0.01, grid.x);
    float gy = smoothstep(0.5, 0.5 - line_width * 0.01, grid.y);
    float lines = max(gx, gy);

    // Neon-ish center energy to support subtle bloom around bright UI blocks.
    float core_glow = smoothstep(0.24, 0.0, d) * 0.15;

    // Touch square pulse.
    vec2 t = abs(UV - touch_center);
    float square = step(t.x, touch_size) * step(t.y, touch_size);
    float touch_ring = smoothstep(touch_size * 1.8, touch_size * 0.8, max(t.x, t.y));
    float touch_fx = max(square, touch_ring * 0.45) * touch_intensity;

    vec3 neon_rgb = vec3(1.2, 1.25, 1.35) * (lines * 0.35 + core_glow + touch_fx * 1.25);
    float alpha = clamp(lines * grid_color.a + touch_fx * 0.35 + core_glow * 0.2, 0.0, 0.65);

    COLOR = vec4(neon_rgb, alpha);
}
