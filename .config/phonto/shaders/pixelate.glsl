#version 300 es
// Pixelate / mosaic. BLOCK_SIZE controls pixel cell size in screen pixels.
precision mediump float;
uniform sampler2D u_tex;
uniform vec2 u_resolution;
in vec2 v_uv;
out vec4 frag_color;

const float BLOCK_SIZE = 6.0;

void main() {
    vec2 block = floor(v_uv * u_resolution / BLOCK_SIZE) * BLOCK_SIZE / u_resolution;
    frag_color = texture(u_tex, block);
}
