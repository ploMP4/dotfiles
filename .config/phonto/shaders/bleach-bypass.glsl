#version 300 es
// Bleach bypass: a darkroom technique that skips the bleach step, leaving
// silver in the print. Result is crushed blacks, blown highlights, and
// heavily desaturated midtones — used in films like Saving Private Ryan
// and Se7en. STRENGTH blends between normal and full bypass (0.0–1.0).
precision mediump float;
uniform sampler2D u_tex;
in vec2 v_uv;
out vec4 frag_color;

const float STRENGTH = 0.85;

void main() {
    vec3 col = texture(u_tex, v_uv).rgb;

    float luma = dot(col, vec3(0.299, 0.587, 0.114));

    // overlay blend: darkens darks, brightens lights, crushes midtones
    vec3 overlay;
    overlay.r = luma < 0.5 ? 2.0 * col.r * luma : 1.0 - 2.0 * (1.0 - col.r) * (1.0 - luma);
    overlay.g = luma < 0.5 ? 2.0 * col.g * luma : 1.0 - 2.0 * (1.0 - col.g) * (1.0 - luma);
    overlay.b = luma < 0.5 ? 2.0 * col.b * luma : 1.0 - 2.0 * (1.0 - col.b) * (1.0 - luma);

    // partial desaturation
    vec3 bypass = mix(vec3(luma), overlay, 0.4);

    frag_color = vec4(mix(col, bypass, STRENGTH), 1.0);
}
