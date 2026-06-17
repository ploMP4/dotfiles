#version 300 es
// RGB channel split radiating from center.
// Tweak STRENGTH to taste (0.003 is subtle, 0.01 is obvious).
precision mediump float;
uniform sampler2D u_tex;
in vec2 v_uv;
out vec4 frag_color;

const float STRENGTH = 0.005;

void main() {
    vec2 dir = v_uv - 0.5;
    float r = texture(u_tex, v_uv + dir * STRENGTH).r;
    float g = texture(u_tex, v_uv).g;
    float b = texture(u_tex, v_uv - dir * STRENGTH).b;
    frag_color = vec4(r, g, b, 1.0);
}
