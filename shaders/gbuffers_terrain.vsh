#version 120

varying vec4 color;
varying vec4 texcoord;
varying vec4 lmcoord;

attribute vec4 mc_Entity;

//Calculate three normally distributed values for random vector using Box-Muller method
vec4 newpos(in vec4 orig){
  float distortionScale = 0.25f;                 //change this when needed -- 0.0f - 1.0f is the sensible range
  float n1, n2, n3;
  vec4 noise = fract(sin(mat4(2.0f, 3.0f, 5.0f, 7.0f, 11.0f, 13.0f, 17.0f, 19.0f, 23.0f, 29.0f, 31.0f, 37.0f, 41.0f, 43.0f, 47.0f, 53.0f)*orig)*43758.5453f);
  n1 = sqrt(-2.0f * log(noise.x)) * sin(6.2831853f*noise.y);
  n2 = sqrt(-2.0f * log(noise.x)) * cos(6.2831853f*noise.y);
  n3 = sqrt(-2.0f * log(noise.z)) * sin(6.2831853f*noise.w);
  return clamp(0.3333333333f*vec4(n1, n2, n3, 0.0f),-1.0f, 1.0f)*0.5*distortionScale;
}

void main() {

  //Calculate offset with trilinear interpolation from full block corners.
  vec4 fg,ff,p1,p2,p3,p4,p5,p6,p7,p8,p12,p34,p56,p78,p1234,p5678,offset;
  if (mc_Entity.x == 0.0) {
    offset = vec4(0.0f); //Don't offset chests
	} else {
    fg = floor(gl_Vertex);
    ff = fract(gl_Vertex);
    p1 = newpos(fg);
    p2 = newpos(fg + vec4(1.0f, 0.0f, 0.0f, 0.0f));
    p3 = newpos(fg + vec4(0.0f, 1.0f, 0.0f, 0.0f));
    p4 = newpos(fg + vec4(1.0f, 1.0f, 0.0f, 0.0f));
    p5 = newpos(fg + vec4(0.0f, 0.0f, 1.0f, 0.0f));
    p6 = newpos(fg + vec4(1.0f, 0.0f, 1.0f, 0.0f));
    p7 = newpos(fg + vec4(0.0f, 1.0f, 1.0f, 0.0f));
    p8 = newpos(fg + vec4(1.0f, 1.0f, 1.0f, 0.0f));
    p12    = p1    + (p2-p1)       * ff.x;
    p34    = p3    + (p4-p3)       * ff.x;
    p56    = p5    + (p6-p5)       * ff.x;
    p78    = p7    + (p8-p7)       * ff.x;
    p1234  = p12   + (p34-p12)     * ff.y;
    p5678  = p56   + (p78-p56)     * ff.y;
    offset = p1234 + (p5678-p1234) * ff.z;
  }
  gl_Position = gl_ModelViewProjectionMatrix * (gl_Vertex + offset);

  texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;
  lmcoord = gl_TextureMatrix[1] * gl_MultiTexCoord1;
  color = gl_Color;
  gl_FogFragCoord = gl_Position.z;
}
