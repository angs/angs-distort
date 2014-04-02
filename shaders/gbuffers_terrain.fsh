#version 120

uniform sampler2D texture;
uniform sampler2D lightmap;
varying vec4 color;
varying vec4 texcoord;
varying vec4 lmcoord;

void main() {
	gl_FragColor = texture2D(texture, texcoord.xy) * texture2D(lightmap, lmcoord.xy) * color;
}
