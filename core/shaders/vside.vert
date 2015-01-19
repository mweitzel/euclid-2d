#version 330 core

layout( location = 0 ) in vec2 pos;
// in vec3 color;
layout( location = 1 ) in float sides;

// out vec3 vColor;
out VS_OUT {
  float vsides;
} vs_out;  
//out float vsides;

void main() {
    gl_Position = vec4(pos, 0.0, 1.0);
//   vColor = vec3( 0.0, 0.0, 1.0 );
    vs_out.vsides = sides;
}
