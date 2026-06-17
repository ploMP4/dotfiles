// Thermal camera / heat map. Remaps luminance through a classic
// black → blue → cyan → green → yellow → red → white palette.
precision mediump float;
uniform sampler2D u_tex;
varying vec2 v_uv;

vec3 thermal(float t) {
    t = clamp(t, 0.0, 1.0);
    vec3 col;
    if (t < 0.25) {
        col = mix(vec3(0.0, 0.0, 0.0), vec3(0.0, 0.0, 1.0), t * 4.0);
    } else if (t < 0.5) {
        col = mix(vec3(0.0, 0.0, 1.0), vec3(0.0, 1.0, 1.0), (t - 0.25) * 4.0);
    } else if (t < 0.75) {
        col = mix(vec3(0.0, 1.0, 1.0), vec3(1.0, 0.5, 0.0), (t - 0.5) * 4.0);
    } else {
        col = mix(vec3(1.0, 0.5, 0.0), vec3(1.0, 1.0, 1.0), (t - 0.75) * 4.0);
    }
    return col;
}

void main() {
    vec3 col = texture2D(u_tex, v_uv).rgb;
    float luma = dot(col, vec3(0.299, 0.587, 0.114));
    gl_FragColor = vec4(thermal(luma), 1.0);
}
