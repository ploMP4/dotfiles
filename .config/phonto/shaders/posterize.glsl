#version 300 es
// Reduces each channel to a fixed number of steps, giving a flat graphic look.
// STEPS = 3 is very aggressive, 6-8 is subtle.
precision mediump float;
uniform sampler2D u_tex;
in vec2 v_uv;
out vec4 frag_color;

const float STEPS = 4.0;

void main() {
    vec3 col = texture(u_tex, v_uv).rgb;
    col = floor(col * STEPS + 0.5) / STEPS;
    frag_color = vec4(col, 1.0);
}
