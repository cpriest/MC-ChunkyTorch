#if !defined(_UTIL_HLSL)
#define _UTIL_HLSL

// This seems to work fine
float3 HUEtoRGB(in float H) {
	float R = abs(H * 6 - 3) - 1;
	float G = 2 - abs(H * 6 - 2);
	float B = 2 - abs(H * 6 - 4);

	return saturate(float3(R,G,B));
}

// This doesn't seem to work
float3 HSLtoRGB(in float3 HSL)  {
	float3 RGB = HUEtoRGB(HSL.x);
	float C = (1 - abs(2 * HSL.z - 1)) * HSL.y;
	return (RGB - 0.5) * C + HSL.z;
}

bool inNether(float2 uv1) {
	return uv1.y < .5;	// Appears that uv1.y is always black in the nether
}

#endif	// _UTIL_HLSL
