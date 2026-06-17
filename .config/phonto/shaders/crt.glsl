// CRT effect: scanlines, slight barrel distortion, and phosphor vignette.
precision mediump float;
uniform sampler2D u_tex;
uniform vec2 u_resolution;
varying vec2 v_uv;

const float SCANLINE_INTENSITY = 0.15;  // 0.0 = none, 0.3 = heavy
const float BARREL = 0.08;             // barrel distortion amount
const float VIGNETTE = 0.35;           // corner darkening strength

vec2 barrel(vec2 uv) {
    vec2 c = uv - 0.5;
    float r2 = dot(c, c);
    return 0.5 + c * (1.0 + BARREL * r2);
}

void main() {
    vec2 uv = barrel(v_uv);

    // kill pixels outside the distorted frame
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    vec3 col = texture2D(u_tex, uv).rgb;

    // scanlines based on screen pixel row
    float line = mod(uv.y * u_resolution.y, 2.0);
    float scan = 1.0 - SCANLINE_INTENSITY * step(1.0, line);
    col *= scan;

    // phosphor vignette
    vec2 vig = uv * (1.0 - uv);
    float v = pow(vig.x * vig.y * 16.0, VIGNETTE);
    col *= v;

    gl_FragColor = vec4(col, 1.0);
}
