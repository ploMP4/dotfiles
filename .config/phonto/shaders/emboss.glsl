#version 300 es
// Emboss / relief effect. Highlights edges as if lit from the top-left.
precision mediump float;
uniform sampler2D u_tex;
uniform vec2 u_resolution;
in vec2 v_uv;
out vec4 frag_color;

void main() {
    vec2 px = 1.0 / u_resolution;
    vec3 tl = texture(u_tex, v_uv + vec2(-px.x,  px.y)).rgb;
    vec3 br = texture(u_tex, v_uv + vec2( px.x, -px.y)).rgb;
    vec3 diff = tl - br;
    float luma = dot(diff, vec3(0.299, 0.587, 0.114));
    // re-center around 0.5 so flat areas are grey
    frag_color = vec4(vec3(luma * 0.5 + 0.5), 1.0);
}
