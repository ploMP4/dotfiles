#version 300 es
// Cyberpunk/neon effect: darkens the image and draws glowing colored edges
// over it. Edge color is pulled from the original pixel, so skin tones glow
// warm, foliage glows green, sky glows blue, etc.
// EDGE_STRENGTH: how bright the glow is (1.5–3.0).
// DARKEN: how much to crush the background (0.0 = black, 0.15 = very dark).
precision mediump float;
uniform sampler2D u_tex;
uniform vec2 u_resolution;
in vec2 v_uv;
out vec4 frag_color;

const float EDGE_STRENGTH = 2.5;
const float DARKEN = 0.08;

void main() {
    vec2 px = 1.0 / u_resolution;

    vec3 col = texture(u_tex, v_uv).rgb;

    // Sobel on luminance
    float tl = dot(texture(u_tex, v_uv + vec2(-px.x,  px.y)).rgb, vec3(0.299, 0.587, 0.114));
    float tc = dot(texture(u_tex, v_uv + vec2(  0.0,  px.y)).rgb, vec3(0.299, 0.587, 0.114));
    float tr = dot(texture(u_tex, v_uv + vec2( px.x,  px.y)).rgb, vec3(0.299, 0.587, 0.114));
    float ml = dot(texture(u_tex, v_uv + vec2(-px.x,   0.0)).rgb, vec3(0.299, 0.587, 0.114));
    float mr = dot(texture(u_tex, v_uv + vec2( px.x,   0.0)).rgb, vec3(0.299, 0.587, 0.114));
    float bl = dot(texture(u_tex, v_uv + vec2(-px.x, -px.y)).rgb, vec3(0.299, 0.587, 0.114));
    float bc = dot(texture(u_tex, v_uv + vec2(  0.0, -px.y)).rgb, vec3(0.299, 0.587, 0.114));
    float br = dot(texture(u_tex, v_uv + vec2( px.x, -px.y)).rgb, vec3(0.299, 0.587, 0.114));
    float gx = -tl - 2.0*ml - bl + tr + 2.0*mr + br;
    float gy = -tl - 2.0*tc - tr + bl + 2.0*bc + br;
    float edge = clamp(sqrt(gx*gx + gy*gy) * EDGE_STRENGTH, 0.0, 1.0);

    // boost color saturation for the glow
    float luma = dot(col, vec3(0.299, 0.587, 0.114));
    vec3 saturated = mix(vec3(luma), col, 2.5);

    vec3 background = col * DARKEN;
    frag_color = vec4(mix(background, saturated, edge), 1.0);
}
