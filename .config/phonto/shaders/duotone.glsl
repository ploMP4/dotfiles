// Maps shadows to one color and highlights to another.
// Change SHADOW and HIGHLIGHT to whatever palette you like.
precision mediump float;
uniform sampler2D u_tex;
varying vec2 v_uv;

const vec3 SHADOW    = vec3(0.05, 0.02, 0.15);  // deep indigo
const vec3 HIGHLIGHT = vec3(0.95, 0.85, 0.50);  // warm gold

void main() {
    vec3 col = texture2D(u_tex, v_uv).rgb;
    float luma = dot(col, vec3(0.299, 0.587, 0.114));
    gl_FragColor = vec4(mix(SHADOW, HIGHLIGHT, luma), 1.0);
}
