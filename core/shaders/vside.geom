#version 330 core

layout(points) in;
layout(line_strip, max_vertices = 50) out;

in float vsides[];

const float PI = 3.1415926;

void main() {
    float fd = vsides[0];
    for (float f=0.0; f<fd; f+=1.0 ) {
      float ang = f * PI * 2.0 / fd;

      vec4 offset = vec4(cos(ang) * 0.075, -sin(ang) * 0.1, 0.0, 0.0);
      gl_Position = gl_in[0].gl_Position + offset;

      EmitVertex();
    }
    vec4 offset = vec4( 0.075, 0.0, 0.0, 0.0 );
    gl_Position = gl_in[0].gl_Position + offset;
    EmitVertex();
/*
    gl_Position = gl_in[0].gl_Position + vec4(0.0, 0.1, 0.0, 0.0);
    EmitVertex();

    gl_Position = gl_in[0].gl_Position + vec4(0.1, 0.0, 0.0, 0.0);
    EmitVertex();

    gl_Position = gl_in[0].gl_Position + vec4(-0.1, 0.0, 0.0, 0.0);
    EmitVertex();
*/
    EndPrimitive();
}
