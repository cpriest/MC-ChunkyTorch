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
float3 HSLtoRGB(in float3 HSL) {
	float3 RGB = HUEtoRGB(HSL.x);
	float C = (1 - abs(2 * HSL.z - 1)) * HSL.y;
	return (RGB - 0.5) * C + HSL.z;
}

bool inNether(float2 uv1) {
	return uv1.y < .5;	// Appears that uv1.y is always black in the nether
}

float luma601(float3 color) {
	const float3 ITUBT709 = { 0.2126, 0.7152, 0.0722 };
	const float3 ITUBT601 = { 0.299, 0.587, 0.114 };

	color *= ITUBT601;
	return color.r + color.g + color.b;
}

float luma709(float3 color) {
	const float3 ITUBT709 = { 0.2126, 0.7152, 0.0722 };
	const float3 ITUBT601 = { 0.299, 0.587, 0.114 };

	color *= ITUBT709;
	return color.r + color.g + color.b;
}


float3 RGBtoHCV(in float3 RGB) {
	float Epsilon = 1e-10;
	// Based on work by Sam Hocevar and Emil Persson
	float4 P = (RGB.g < RGB.b) ? float4(RGB.bg, -1.0, 2.0/3.0) : float4(RGB.gb, 0.0, -1.0/3.0);
	float4 Q = (RGB.r < P.x) ? float4(P.xyw, RGB.r) : float4(RGB.r, P.yzx);
	float C = Q.x - min(Q.w, Q.y);
	float H = abs((Q.w - Q.y) / (6 * C + Epsilon) + Q.z);
	return float3(H, C, Q.x);
}

float3 RGBtoHCY(in float3 RGB) {
	// The weights of RGB contributions to luminance.
	// Should sum to unity.
	float3 HCYwts = float3(0.299, 0.587, 0.114);
		float Epsilon = 1e-10;

	// Corrected by David Schaeffer
	float3 HCV = RGBtoHCV(RGB);
	float Y = dot(RGB, HCYwts);
	float Z = dot(HUEtoRGB(HCV.x), HCYwts);
	if (Y < Z)
	{
		HCV.y *= Z / (Epsilon + Y);
	}
	else
	{
		HCV.y *= (1 - Z) / (Epsilon + 1 - Y);
	}
	return float3(HCV.x, HCV.y, Y);
}

float3 HCYtoRGB(in float3 HCY) {
	// The weights of RGB contributions to luminance.
	// Should sum to unity.
	float3 HCYwts = float3(0.299, 0.587, 0.114);

	float3 RGB = HUEtoRGB(HCY.x);
	float Z = dot(RGB, HCYwts);
	if (HCY.z < Z)
	{
		HCY.y *= HCY.z / Z;
	}
	else if (Z < 1)
	{
		HCY.y *= (1 - HCY.z) / (1 - Z);
	}
	return (RGB - Z) * HCY.y + HCY.z;
	}

float3 AdjustLumosity(float3 rgb, float adj) {
	float3 hcy = RGBtoHCY(rgb);
	hcy.z = max(hcy.z, adj);
	return HCYtoRGB(hcy);
}

float easeOutCubic(float x) {
	return 1 - pow(1 - x, 3);
}

#endif	// _UTIL_HLSL
