precision highp float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 color = texture2D(tex, v_texcoord);
    
    // Teinte bleue basée sur tes couleurs
    vec3 tint = vec3(0.4, 0.6, 0.85);
    color.rgb = mix(color.rgb, color.rgb * tint, 0.15);
    
    gl_FragColor = color;
}
