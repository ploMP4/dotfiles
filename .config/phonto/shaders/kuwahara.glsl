#version 300 es
// Kuwahara oil-painting filter. Samples 4 overlapping windows around each
// pixel and outputs the mean of the one with the lowest variance — smooths
// flat regions while sharpening edges, making video look painted.
// Raise RADIUS for a heavier brush (costs more GPU; 2-4 is the sweet spot).
precision mediump float;
uniform sampler2D u_tex;
uniform vec2 u_resolution;
in vec2 v_uv;
out vec4 frag_color;

const int RADIUS = 3;

void main() {
    vec2 px = 1.0 / u_resolution;
    float n = float((RADIUS + 1) * (RADIUS + 1));

    vec3 m0 = vec3(0.0), m1 = vec3(0.0), m2 = vec3(0.0), m3 = vec3(0.0);
    vec3 s0 = vec3(0.0), s1 = vec3(0.0), s2 = vec3(0.0), s3 = vec3(0.0);

    for (int x = -RADIUS; x <= 0; x++) {
        for (int y = -RADIUS; y <= 0; y++) {
            vec3 c = texture(u_tex, v_uv + vec2(float(x), float(y)) * px).rgb;
            m0 += c; s0 += c * c;
        }
    }
    for (int x = 0; x <= RADIUS; x++) {
        for (int y = -RADIUS; y <= 0; y++) {
            vec3 c = texture(u_tex, v_uv + vec2(float(x), float(y)) * px).rgb;
            m1 += c; s1 += c * c;
        }
    }
    for (int x = -RADIUS; x <= 0; x++) {
        for (int y = 0; y <= RADIUS; y++) {
            vec3 c = texture(u_tex, v_uv + vec2(float(x), float(y)) * px).rgb;
            m2 += c; s2 += c * c;
        }
    }
    for (int x = 0; x <= RADIUS; x++) {
        for (int y = 0; y <= RADIUS; y++) {
            vec3 c = texture(u_tex, v_uv + vec2(float(x), float(y)) * px).rgb;
            m3 += c; s3 += c * c;
        }
    }

    m0 /= n; s0 = abs(s0 / n - m0 * m0);
    m1 /= n; s1 = abs(s1 / n - m1 * m1);
    m2 /= n; s2 = abs(s2 / n - m2 * m2);
    m3 /= n; s3 = abs(s3 / n - m3 * m3);

    float v0 = s0.r + s0.g + s0.b;
    float v1 = s1.r + s1.g + s1.b;
    float v2 = s2.r + s2.g + s2.b;
    float v3 = s3.r + s3.g + s3.b;

    vec3 result = m0;
    float minV = v0;
    if (v1 < minV) { minV = v1; result = m1; }
    if (v2 < minV) { minV = v2; result = m2; }
    if (v3 < minV) {             result = m3; }

    frag_color = vec4(result, 1.0);
}
