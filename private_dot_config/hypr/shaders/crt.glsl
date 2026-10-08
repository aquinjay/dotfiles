#version 300 es
// CRT look for the Fallout Terminal theme: scanlines, slight phosphor glow and vignette.
// Enabled by the preset's "screen_shader" style value; other themes turn it off.
precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 color = texture(tex, v_texcoord);

    // soft horizontal bloom
    vec2 px = vec2(1.5 / 1920.0, 0.0);
    vec3 bloom = (texture(tex, v_texcoord + px).rgb + texture(tex, v_texcoord - px).rgb) * 0.5;
    color.rgb = mix(color.rgb, max(color.rgb, bloom), 0.35);

    // scanlines every 3 physical pixels
    float scan = mod(gl_FragCoord.y, 3.0) < 1.0 ? 0.82 : 1.0;

    // vignette
    vec2 d = v_texcoord - 0.5;
    float vig = clamp(1.0 - dot(d, d) * 0.9, 0.0, 1.0);

    fragColor = vec4(color.rgb * scan * vig, color.a);
}
