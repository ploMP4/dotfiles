#version 300 es
// Smooth vignette with a slight warm color grade.
// STRENGTH controls how dark the corners get (0.0–1.0).
precision mediump float;
uniform sampler2D u_tex;
in vec2 v_uv;
out vec4 frag_color;

const float STRENGTH = 0.55;

void main() {
    vec3 col = texture(u_tex, v_uv).rgb;

    vec2 uv = v_uv * (1.0 - v_uv);
    float vig = pow(uv.x * uv.y * 16.0, STRENGTH);

    // subtle warm lift in the shadows
    col = mix(vec3(0.08, 0.04, 0.02), col, vig);

    frag_color = vec4(col, 1.0);
}
