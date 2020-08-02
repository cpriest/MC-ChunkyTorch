#if !defined(_SHAPES_HLSL)
#define _SHAPES_HLSL

#include "funcs/macros.hlsl"

float and(float1 xyz) { return xyz.x; }
float and(float2 xyz) { return xyz.x * xyz.y; }
float and(float3 xyz) { return xyz.x * xyz.y * xyz.z; }

float rect(float2 pos, float2 center, float2 size, float2 edge) {
	return and(
		smoothstep(center-size-edge, center-size, pos) - smoothstep(center+size, center+size+edge, pos)
	);
}

float rect(float2 pos, float2 center, float2 size) {
	return rect(pos, center, size, .01);
}

float box(float2 pos, float2 center, float2 size) {
	float2 r = step(center-size, pos) - step(center+size, pos);
	return (r.x * r.y);
}

float box(float2 pos, float2 center, float2 size, float2 edge) {
	return box(pos, center, size + edge) * (1-box(pos, center, size ));
}

float distcirc(float2 pos, float diameter, float edge) {
	return smoothstep(diameter, diameter + edge, distance(pos, .5));
}

float circle(float2 pos, float radius, float edge) {
	return smoothstep(radius - edge, radius, length(pos -.5));
}

#endif	// _SHAPES_HLSL
