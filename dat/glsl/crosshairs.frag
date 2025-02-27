#include "lib/sdf.glsl"

uniform vec4 color;
uniform vec2 dimensions;
uniform float r;

in vec2 pos;
out vec4 color_out;

void main(void) {
   float m = 1.0 / dimensions.x;
   float rad = 1.0 - r*m;
   float d = min(
      length( pos - vec2( clamp( pos.x, -rad, rad ), 0.0 ) ),
      length( pos - vec2( 0.0, clamp( pos.y, -rad, rad ) ) )
   );
   float alpha = smoothstep(-m, 0.0, -d);
   float beta  = smoothstep(-r*m, -m, -d);
   color_out   = color * vec4( vec3(alpha), beta );
}
