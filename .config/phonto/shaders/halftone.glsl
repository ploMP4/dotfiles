// Newspaper/comic halftone dots. Luminance controls dot radius within each
// cell — bright areas have large dots, dark areas have small ones.
// CELL_SIZE: dot grid cell size in screen pixels (6–12 looks good).
precision mediump float;
uniform sampler2D u_tex;
uniform vec2 u_resolution;
varying vec2 v_uv;

const float CELL_SIZE = 8.0;

void main() {
    // sample at the center of this pixel's cell
    vec2 cell = floor(v_uv * u_resolution / CELL_SIZE);
    vec2 cell_center_uv = (cell * CELL_SIZE + CELL_SIZE * 0.5) / u_resolution;
    vec3 col = texture2D(u_tex, cell_center_uv).rgb;

    float luma = dot(col, vec3(0.299, 0.587, 0.114));

    // distance from pixel to cell center, in cell-local [0,1] space
    vec2 local = fract(v_uv * u_resolution / CELL_SIZE) - 0.5;
    float dist = length(local);

    // dot radius: sqrt keeps dot area proportional to luminance
    float radius = sqrt(luma) * 0.5;

    float inside = step(dist, radius);
    gl_FragColor = vec4(col * inside, 1.0);
}
