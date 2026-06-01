#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform float uIntensity;
uniform float uSpeed;

out vec4 fragColor;

float noise(vec2 p) {
    return sin(p.x) * sin(p.y);
}

void main() {

    vec2 uv = FlutterFragCoord().xy / uSize;

    float t = uTime * uSpeed;

    float wave =
        sin((uv.x * 8.0) + t) *
        0.3 +

        sin((uv.y * 10.0) + t * 1.4) *
        0.2;

    float glow =
        smoothstep(
          0.1,
          0.8,
          wave + uv.y
        );

    vec3 color = mix(
      vec3(0.0,0.2,1.0),
      vec3(0.7,0.0,1.0),
      glow
    );

    color *= uIntensity;

    fragColor = vec4(color,1.0);
}