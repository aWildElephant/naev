#include "lib/sdf.glsl"

uniform vec4 color;
uniform vec2 dimensions;
uniform float r;

in vec2 pos;
out vec4 color_out;

void main(void) {
   float d = sdCircle( pos*dimensions, dimensions.x-1.0 );
   if (r==0.0)
      d = abs(d);
   /*
   float alpha = smoothstep(-m, 0.0, -d);
   float beta  = smoothstep(-2.0*m, -m, -d);
   color_out   = color * vec4( vec3(alpha), beta );
   */
   float alpha = smoothstep(-1.0, 0.0, -d);
   color_out   = color;
   color_out.a *= alpha;
}


