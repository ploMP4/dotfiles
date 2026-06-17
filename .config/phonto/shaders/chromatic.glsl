// RGB channel split radiating from center.
// Tweak STRENGTH to taste (0.003 is subtle, 0.01 is obvious).
precision mediump float;
uniform sampler2D u_tex;
varying vec2 v_uv;

const float STRENGTH = 0.005;

void main() {
    vec2 dir = v_uv - 0.5;
    float r = texture2D(u_tex, v_uv + dir * STRENGTH).r;
    float g = texture2D(u_tex, v_uv).g;
    float b = texture2D(u_tex, v_uv - dir * STRENGTH).b;
    gl_FragColor = vec4(r, g, b, 1.0);
}
