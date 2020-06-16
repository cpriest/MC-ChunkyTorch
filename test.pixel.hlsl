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

#define freq 20.0
#define freqDiv 1.0 / freq

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
	// The number of squares shown vertically, horizontally as well with 1:1 pixel ratio
	// float freq = 20.0;

	// Uncomment to animate grid in/out
	// freq = ceil(5+abs(sin(iTime/100)*200));
	// freq = ceil(5+abs(sin(iTime/200)*10));
	// freq  = 5;
	// freq  = 10;
	// freq  = 15;
	// freq  = 20;
	// freq  = 50;

	// The division of the frequency in 0-1 terms
	// float freqDiv = 1.0 / freq;

// ----- Offset Grid via sin() -----
	// Calculate 4 sine waves based on uv and uv offset by 1/100th of freq
	float4 uvS = float4(uv.x, uv.y, uv.x - freqDiv, uv.y - freqDiv);
	float4 sine = sin(uvS * PI * freq / 2) / freq;

	// Smoothstep as each approaches 0
	float spread = 0.01;
	float4 sineStep = smoothstep(-spread, 0, sine) - smoothstep(0, spread, sine);


	// For each pair (xy), (zw), color a dot
	col.g += sineStep.x * sineStep.y + sineStep.z * sineStep.w;

	float divX = floor(uv.x / freqDiv),
		  divY = floor(uv.y / freqDiv);

	float tWave = 1;
	// tWave = sin(iTime/50)*20;

	boxes._m00 = freqDiv == .05;
	for(float j=0; j <= 1.0 ; j+=freqDiv*2) {
		col.g += smoothline(sine.x, .01, (uv.y - j) * freq/2 / tWave);
		col.g += smoothline(sine.y, .01, (uv.x - j) * freq/2 / tWave);
		col.g += smoothline(sine.z, .01, (uv.y - freqDiv - j) * freq/2 / tWave);
		col.g += smoothline(sine.w, .01, (uv.x - freqDiv - j) * freq/2 / tWave);
	}

	// col.g += smoothline(sine.x, .014, (uv.y + freqDiv * (divY-2)) * freq/2);
	// col.g += smoothline(sine.y, .014, (uv.x + -freqDiv * (divX-freqDiv)) * freq/2);
	// col.g += smoothline(sine.z, .014, (uv.y + -freqDiv * (divY)) * freq/2);
	// col.g += smoothline(sine.w, .014, (uv.x - freqDiv*3) * freq/2);
	// col.g += smoothline(sine.w, .014, (uv.x - freqDiv*5) * freq/2);
	// col.g += smoothline(sine.w, .014, (uv.x - freqDiv * divX) * freq/2);

	// float4 sineLine = smoothstep(-spread, 0, sine) - smoothstep(0, spread, sine);

	// Visualize quad sin waves
	// ** Refactor to use uvS??
	// for(float j=0.0; j<1.0; j+=0.05) {
	// 	col.g += sinline(uv.x - j, uv.y - j, freq / 2, freq / 2 /* / (sin(iTime/100)*30) */ ) /* *(sin(iTime/50))*/;
	// 	col.g += sinline(uv.y - j, uv.x - j, freq / 2, freq / 2 /* / (sin(iTime/100)*30) */ ) /* *(sin(iTime/50))*/;
	// }



// ----- Red / Blue Grid -----
	// Red/Blue Grid based on frequency
	//  5 - 0.0038108
	// 50 - 0.004982
	float mn8=0.004982,		// Some magic number that multiplies by frequency
		  thresh = mn8 * freq;	// appropriately to serve as threshold
	float2 xy = sin(uv*PI*freq);
	col.rb += step(thresh, smoothline(0, thresh/2, xy));

	// Colors everyting white if x/y resolution is 1:1
	// if(iResolution.x / iResolution.y == 1)
	// 	col = 1;

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


