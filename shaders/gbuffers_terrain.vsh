#version 120

varying vec4 color;
varying vec4 texcoord;
varying vec4 lmcoord;

attribute vec4 mc_Entity;

  #define JUST_A_LITTLE_BIT //Small increment
//#define A_LITTLE_BIT_MORE //Double increment
//#define U_KNOW_WHAT_IM_LOOKING_FOR //Quadruple increment

float cycle = 2.0f*3.141592653589793/16.0f;

float p3 = pow(0.125f, (1.0 / 7.0));
float p2 = p3*p3;
float p1 = p2*p2;
#if defined(U_KNOW_WHAT_IM_LOOKING_FOR) && defined(A_LITTLE_BIT_MORE) && defined(JUST_A_LITTLE_BIT)
float distortionScale = 1.0f;
#elif defined(U_KNOW_WHAT_IM_LOOKING_FOR) && defined(A_LITTLE_BIT_MORE)
float distortionScale = p3;
#elif defined(U_KNOW_WHAT_IM_LOOKING_FOR) && defined(JUST_A_LITTLE_BIT)
float distortionScale = p2;
#elif defined(A_LITTLE_BIT_MORE) && defined(JUST_A_LITTLE_BIT)
float distortionScale = p1;
#elif defined(U_KNOW_WHAT_IM_LOOKING_FOR)
float distortionScale = p2 * p3;
#elif defined(A_LITTLE_BIT_MORE)
float distortionScale = p1 * p3;
#elif defined(JUST_A_LITTLE_BIT)
float distortionScale = p1 * p2;
#else
float distortionScale = p1 * p2 * p3;
#endif

//For optifine/shadermod to accept these as options
#ifdef A_LITTLE_BIT_MORE  
#endif
#ifdef U_KNOW_WHAT_IM_LOOKING_FOR
#endif
#ifdef JUST_A_LITTLE_BIT
#endif

//Calculate three normally distributed values for random vector using Box-Muller method
vec4 newpos(in vec4 orig){
  float n1, n2, n3;
	//Pseudo-random uniform vector from vertex with 16×16×16 cyclical pattern
  vec4 noise = fract(sin(mat4
    (2.0f,  3.0f,  5.0f,  7.0f, 
    11.0f, 13.0f, 17.0f, 19.0f, 
    23.0f, 29.0f, 31.0f, 37.0f, 
    41.0f, 43.0f, 47.0f, 53.0f)
    *sin(orig*cycle))*43758.5453f);
  //Box-Muller transform
  n1 = sqrt(-2.0f * log(noise.x)) * sin(6.2831853f*noise.y);
  n2 = sqrt(-2.0f * log(noise.x)) * cos(6.2831853f*noise.y);
  n3 = sqrt(-2.0f * log(noise.z)) * sin(6.2831853f*noise.w);
	//Scale and limit offset to 0.5 blocks in every direction 
  return clamp(0.3333333333f*vec4(n1, n2, n3, 0.0f),-1.0f, 1.0f)*0.5*distortionScale;
}

void main() {
  //Calculate offset with trilinear interpolation from full block corners.
  vec4 fg,ff,p1,p2,p3,p4,p5,p6,p7,p8,p12,p34,p56,p78,p1234,p5678,offset;
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
  gl_Position = gl_ModelViewProjectionMatrix * (gl_Vertex + offset);

  texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;
  lmcoord = gl_TextureMatrix[1] * gl_MultiTexCoord1;
  color = gl_Color;
  gl_FogFragCoord = gl_Position.z;
}
