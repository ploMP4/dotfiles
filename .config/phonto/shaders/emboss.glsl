// Emboss / relief effect. Highlights edges as if lit from the top-left.
precision mediump float;
uniform sampler2D u_tex;
uniform vec2 u_resolution;
varying vec2 v_uv;

void main() {
    vec2 px = 1.0 / u_resolution;
    vec3 tl = texture2D(u_tex, v_uv + vec2(-px.x,  px.y)).rgb;
    vec3 br = texture2D(u_tex, v_uv + vec2( px.x, -px.y)).rgb;
    vec3 diff = tl - br;
    float luma = dot(diff, vec3(0.299, 0.587, 0.114));
    // re-center around 0.5 so flat areas are grey
    gl_FragColor = vec4(vec3(luma * 0.5 + 0.5), 1.0);
}
