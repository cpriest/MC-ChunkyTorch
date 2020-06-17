#define PI 3.14159265359

float2 iResolution;
float iTime;

float Line(float n, float pixWidth, float alpha){
    return smoothstep(n - pixWidth/iResolution.x, n, alpha)
		- smoothstep(n, n  + pixWidth/iResolution.x, alpha);
}

// #include "test.pixel.grid1.hlsl"
// #include "test.pixel.grid2.hlsl"
#include "my.util.hlsl"

float smoothline(float center, float feather, float at) {
	return smoothstep(center-feather, center, at)
		 - smoothstep(center, center+feather, at);
}

float2 smoothline(float2 center, float2 feather, float2 at) {
	return float2(
		smoothline(center.x, feather.x, at.x),
		smoothline(center.y, feather.y, at.y)
	);
}

float sinline(float x, float y, float freq, float amp=5) {
	// float PI = 3.14159265359;
	float thresh = 0.038107;

	float sine = sin(x * PI * freq) / amp;

	float col = smoothline(sine, .014, y * freq);

	return col;
}

float box(float2 uv, float2 xy, float2 size) {
	float2 r = step(xy-size, uv) - step(xy+size, uv);
	return (r.x * r.y);
}

// float2 sinline(float2 col, float2 uv, float2 freq) {
// 	// float PI = 3.14159265359;
// 	float thresh = 0.038107;

// 	float2 xy = sin(uv * PI * freq) / 5;

// 	col.r = smoothline(xy.x, .01, uv.y * freq);
// 	col.g = smoothline(xy.y, .01, uv.x * freq);

// 	return col;
// }

float4 main_PixelGrid2(in float2 uv: TEXCOORD0) : SV_Target {
	float4 red = float4(.8, 0, 0, .5);
	float4 green = float4(0, .8, 0, .5);
	float4 blue = float4(0, 0, .8, .5);
	float _;
	float4 col = 0;

	float1x4 boxes = 0;

	// uv -= 0.5;

	// float4 br = box(uv, float2(.125, .03), (float2).009);
	// if(br.x == 1.0)
	// 	col = br * float4(1,1,0,1);
	// // return col;

// ----- INPUTS -----
#define freq 20.0
#define freqDiv 1.0 / freq
	// The number of squares shown vertically, horizontally as well with 1:1 pixel ratio
	// float freq = 20.0;

	// Uncomment to animate grid in/out (doesn't work with freq being a #define)
	// freq = ceil(5+abs(sin(iTime/100)*200));
	// freq = ceil(5+abs(sin(iTime/200)*10));

// ----- Offset Grid via sin() -----
	// Calculate 4 sine waves based on uv and uv offset by freqDiv
	float4 uvS = float4(uv.x, uv.y, uv.x - freqDiv, uv.y - freqDiv);
	float4 sine = sin(uvS * PI * freq / 2) / freq;

	// Smoothstep as each approaches 0
	float spread = 0.01;
	float4 sineStep = smoothstep(-spread, 0, sine) - smoothstep(0, spread, sine);

	// For each pair (xy), (zw), color a dot
	col.g += sineStep.x * sineStep.y + sineStep.z * sineStep.w;

	// boxes._m00 = freqDiv == .05;

// ----- Animated Waves of Lines -----
	// #define WAVES

	#ifdef WAVES
		float tWave = 1;
		tWave = sin(iTime/50)*20;
		float tAbsWave = abs(tWave);

		for(float j=0; j <= 1.0; j+=freqDiv*2) {
			float4 pct = float4(smoothline(sine.x, .002, (uv.y - j) * freq/2 / tWave)
					, smoothline(sine.y, .002, (uv.x - j) * freq/2 / tWave)
					, smoothline(sine.z, .002, (uv.y - freqDiv - j) * freq/2 / tWave)
					, smoothline(sine.w, .002, (uv.x - freqDiv - j) * freq/2 / tWave)
			);
			float pctT = pct.x + pct.y + pct.z + pct.w;

			// float colS = abs(cos(iTime/5 * j)) * pct;

			// col.g += pctT;
			// col.rgb += float3(2 * pct.x, 2*pct.z, 3*pct.y);
			col.g += pctT;
		}
	#endif

// ----- Red / Blue Grid -----
	// Red/Blue Grid based on frequency
	//  5 - 0.0038108
	// 50 - 0.004982
	float mn8=0.004982,		// Some magic number that multiplies by frequency
		  thresh = mn8 * freq;	// appropriately to serve as threshold
	float2 xy = sin(uv*PI*freq);
	col.rb += step(thresh, smoothline(0, thresh/2, xy));

	// Colors everyting white if x/y resolution is 1:1
	boxes._m03 = iResolution.x / iResolution.y == 1;

	col += float4(1, 1, 1, 1) * box(uv, float2(.075, .03), (float2).009) * boxes._m00;
	col += float4(1, 1, 1, 1) * box(uv, float2(.125, .03), (float2).009) * boxes._m01;
	col += float4(1, 1, 1, 1) * box(uv, float2(.175, .03), (float2).009) * boxes._m02;
	col += float4(1, 1, 1, 1) * box(uv, float2(.225, .03), (float2).009) * boxes._m03;
	return col;
}

float4 main(in float2 uv : TEXCOORD0 ) : SV_Target {
    uv.x *= iResolution.x/iResolution.y;
	float4 col = .5;

	return main_PixelGrid2(uv);
	return col;
}


