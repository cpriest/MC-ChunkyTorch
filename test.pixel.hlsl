#define PI 3.14159265359
#define amplitude .5
#define speed 2.

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
	float gridSize = 16;
	float _;
	float4 col = 0;

	float2 uvs = uv * iResolution;



	// col.rg = float2(sin(uv.x), sin(uv.y));
	// col.rb = /* sin(uv.x)  */ cos(uv.xy);
	// col.g = fmod(frac(uv.x), .1) == 0;

	// float sine = .5 + (sin(uvs.x));
	// float sineCurve = Line(sine, 5, uv.y);

    // col.rgb += float3(sineCurve * .2, sineCurve * .35, sineCurve * .5);
	// if(cos(uvs.x*100*PI) >= .9)

	// 0.00381072
	float
		freq = 10.0f,
		amp = 10,
		freqDiv = 1 / freq
		;


	// Calculate 4 sine waves based on uv and uv offset by 1/100th of freq
	float4 uvS = float4(uv.x, uv.y, uv.x - freqDiv, uv.y - freqDiv);
	float4 sine = sin(uvS * PI * freq / 2) / freq;

	// Smoothstep as each approaches 0
	float spread = .015;
	float4 sineStep = smoothstep(-spread, 0, sine) - smoothstep(0, spread, sine);

	// For each pair (xy), (zw), color a dot
	col.g = sineStep.x * sineStep.y + sineStep.z * sineStep.w;


	// Visualize quad sin waves
	// ** Refactor to use uvS??
	// for(float j=0.0f; j<1.0f; j+=0.1 /* freqDiv */) {
	// 	col.g += sinline(uv.x - j, uv.y - j, freq / 2, freq) /* *(sin(iTime/50))*/;
	// 	col.g += sinline(uv.y - j, uv.x - j, freq / 2, freq) /* *(sin(iTime/50))*/;
	// }
	// col.rb += sinline(col.rb, float2(uv.x - 0.5, uv.y - 0.4), freq / 2);

	// Red/Blue Grid #2
	float	mn8=0.0043450070,	// Some magic number that multiplies by frequency appropriately
		thresh = mn8 * freq;	// To serve as threshold
	float2 xy = sin(uv*PI*freq);
	col.rb += step(thresh, smoothline(0, thresh/2, xy));
	// col.g += col.r + col.b;

	// Tinker from Red/Blue Grid
	// float2 xy = sin(uv*PI*freq);
	// float2 xy2 = cos(uv*PI*freq/2);
	// float2 xy3 = sin(uv*PI*freq/2);

	// col.rb = step(thresh, smoothline(0, thresh/2, xy));
	// col.g = step(thresh, smoothline(0, thresh/2, xy2)).x;
	// col.b = step(thresh, smoothline(0, thresh/2, xy3)).x;

	// if(all(step(thresh, smoothline(0, thresh/2, xy)) == float2(1,1)))
	// 	col = 1;



	// Red/Blue Grid based on cosine
	// freq = 20, thresh = 0.99774135;
	// col.r = step(thresh, cos(uv.x*PI*freq));
	// col.b = step(thresh, cos(uv.y*PI*freq));


	// if(iResolution.x / iResolution.y == 1)
	// 	col = 1;

	return col;
}

float4 main(in float2 uv : TEXCOORD0 ) : SV_Target {
    uv.x *= iResolution.x/iResolution.y;
	float4 col = .5;

	return main_PixelGrid2(uv);
	return col;
}


