// Pixelate / mosaic. BLOCK_SIZE controls pixel cell size in screen pixels.
precision mediump float;
uniform sampler2D u_tex;
uniform vec2 u_resolution;
varying vec2 v_uv;

const float BLOCK_SIZE = 6.0;

void main() {
    vec2 block = floor(v_uv * u_resolution / BLOCK_SIZE) * BLOCK_SIZE / u_resolution;
    gl_FragColor = texture2D(u_tex, block);
}
