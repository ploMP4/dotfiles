// Reduces each channel to a fixed number of steps, giving a flat graphic look.
// STEPS = 3 is very aggressive, 6-8 is subtle.
precision mediump float;
uniform sampler2D u_tex;
varying vec2 v_uv;

const float STEPS = 4.0;

void main() {
    vec3 col = texture2D(u_tex, v_uv).rgb;
    col = floor(col * STEPS + 0.5) / STEPS;
    gl_FragColor = vec4(col, 1.0);
}
