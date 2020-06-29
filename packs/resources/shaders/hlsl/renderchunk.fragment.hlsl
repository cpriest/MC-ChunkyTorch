#include "ShaderConstants.fxh"
#include "util.fxh"

struct PS_Input
{
	float3 chunkPosition : CHUNK_POS;
	float4 position : SV_Position;
	float3 wPos : worldPos;

#ifndef BYPASS_PIXEL_SHADER
	lpfloat4 color : COLOR;
	snorm float2 uv0 : TEXCOORD_0_FB_MSAA;
	snorm float2 uv1 : TEXCOORD_1_FB_MSAA;
#endif

#ifdef FOG
	float4 fogColor : FOG_COLOR;
#endif
};

struct PS_Output
{
	float4 color : SV_Target;
};

#define between(var, low, high) (abs(var) >= low && abs(var) <= high)


float2 square(float2 center, float2 size, float2 pos) {
	return smoothstep(center-size, center, pos) - smoothstep(center, center+size, pos);
}
float2 square(float2 center, float2 size, float2 edge, float2 pos) {
	return smoothstep(center-size-edge, center-size, pos) - smoothstep(center+size, center+size+edge, pos);
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

/**  mul(vector, matrix) == mul(transpose(matrix), vector) **/
/*
		Deviations					STR8	mul(WORLD)	mul(transpose(WORLD))
*/

float3 tulm(float3 pos, float4x4 mat) { return mul(float4(pos, 1), mat); }
float3 mult(float3 pos, float4x4 mat) { return mul(mat, float4(pos, 1)); }

float3 testing(float3 color, in PS_Input psi) {

	return color;

	float3 red = {1, 0, 0}, green={0,1,0}, blue={0,0,1};
	float3 chPos = psi.position.xyz;
	float3 pos, chunkNum;

	pos = modf(chPos, chunkNum) + .5;

	// float3 chunkNum, pos = modf(psi.chunkPosition.xyz / 16, chunkNum);

	// psi.wPos(0, 0) = Camera Position In World
	// psi.chunkPosition = 1.0 - 16.0 Repeated

	float3 worldPos = (psi.chunkPosition.xyz * CHUNK_ORIGIN_AND_SCALE.w) + CHUNK_ORIGIN_AND_SCALE.xyz;

	float3 xpI, xp = modf(psi.chunkPosition.xyz, xpI);
	// float3 xpI2, xp2 = modf(psi.wPos.xyz, xpI2);

	// worldPos = mul(WORLD, float4(worldPos, 1));
	// float3 xpI3, xp3 = modf(worldPos, xpI3);

	// worldPos = mul(WORLD, float4( psi.position.xyz, psi.position.w ));
	// float3 xpI4, xp4 = modf(worldPos, xpI4);

	// float3 tPos = VIEW_POS * CHUNK_ORIGIN_AND_SCALE.w;
	// float3 tPos1 = tPos;
	// float3 tPos2 = mult(tPos, PROJ);
	// float3 tPos3 = tulm(tPos, PROJ);
	// float3 tPos4 = mult(tPos, transpose(PROJ));
	// float3 tPos5 = tulm(tPos, transpose(PROJ));

	/*								#1 		#2 			#3			#4				#5
		Deviations					STR8	mul(WORLD)	tulm(WORLD)	mult(xp(WORLD))	tulm(xp(WORLD))
		          					STR8	mul(PROJ)	tulm(PROJ)	mult(xp(PROJ))	tulm(xp(PROJ))
			psi.position 			✓✓		✓✓			✓✓			✓✓				✓✓
			psi.chunkPosition 		✓✓		✓✓			✓✓			✓✓				✓✓
			psi.wPos  				✓✓		✓✓			✓✓			✓✓				✓✓
			psi.vs_pos 				✓✓		✓✓			✓✓			✓✓				✓✓
	*/
	float3 	mix1 = 1;

	// tPos1.x = tPos2.x = tPos3.x = tPos4.x = tPos5.x = 7000.0;
	mix1 = float3(
		abs(xp.x),
		abs(xp.z),
		abs(.5)
	);

	bool b0 = 0, b1 = 0,  b2 = 0,  b3 = 0,  b4 = 0,  b5 = 0,  b6 = 0,  b7 = 0;
	bool b8 = 0, b9 = 0, b10 = 0, b11 = 0, b12 = 0, b13 = 0, b14 = 0, b15 = 0;

	// b1 = between(floor(tPos1.x), 6900, 7100);
	// b2 = between(floor(tPos2.x), 6900, 7100);
	// b3 = between(floor(tPos3.x), 6900, 7100);
	// b4 = between(floor(tPos4.x), 6900, 7100);
	// b5 = between(floor(tPos5.x), 6900, 7100);

	// b1 = between(psi.vs_pos.x,    0,    1);
	// b2 = between(psi.vs_pos.x,    1,    2);
	// b3 = between(psi.vs_pos.x,    2,    5);
	// b4 = between(psi.vs_pos.x,    5,   10);
	// b5 = between(psi.vs_pos.x,   50,  100);
	// b6 = between(psi.vs_pos.x,   50,  100);
	// b7 = between(psi.vs_pos.x, 4000, 6000);
	// b8 = between(psi.vs_pos.x, 6000, 8000);

	// b1 = xpI3.x >= 0 && xpI3.x < 16;
	// b2 = xpI3.x >= 16 && xpI3.x < 32;
	// b3 = xpI3.x >= 6950 && xpI3.x < 7050;
	// b4 = xpI3.x == 7010;// && xpI4.x < 16;
	// b6 = xpI4.x >= 0 && xpI4.x < 16;
	// b7 = xpI4.x >= 16 && xpI4.x < 32;
	// b8 = xpI4.x >= 6950 && xpI4.x < 7050;
	// b9 = xpI4.x == 7010;// && xpI4.x < 16;
	// b8 = xpI4.x >= 16 && xpI4.x < 32;

	// if(xpI.x == 0 && ((xpI.z >=1 && xpI.z <=4) || (xpI.z >=6 && xpI.z <=9)))
	if(xpI.x == 0 && xpI.z <= 16)
		color = lerp(color, mix1, .4);
	else if(xpI.x == 1) {
		if(xpI.z == 0)
			color = lerp(color, mix1, .4);
		else if( 	(xpI.z == 0 && b0) || (xpI.z == 8 && b8) ||
					(xpI.z == 1 && b1) || (xpI.z == 9 && b9) ||
					(xpI.z == 2 && b2) || (xpI.z == 10 && b10) ||
					(xpI.z == 3 && b3) || (xpI.z == 11 && b11) ||
					(xpI.z == 4 && b4) || (xpI.z == 12 && b12) ||
					(xpI.z == 5 && b5) || (xpI.z == 13 && b13) ||
					(xpI.z == 6 && b6) || (xpI.z == 14 && b14) ||
					(xpI.z == 7 && b7) || (xpI.z == 15 && b15)
				 )
			color = lerp(color, mix1, .4);
	}
	else if(xpI.x == 2) {
		float3 vs_pos = psi.position.xyz;
		if(xpI.z == 1)
			return float3(vs_pos.x, vs_pos.z, 0);
		if(xpI.z == 2)
			return float3(vs_pos.x /  10, vs_pos.z /  10, 0);
		if(xpI.z == 3)
			return float3(vs_pos.x /  20, vs_pos.z /  20, 0);
		if(xpI.z == 4)
			return float3(vs_pos.x /  30, vs_pos.z /  30, 0);
		if(xpI.z == 5)
			return float3(vs_pos.x /  40, vs_pos.z /  40, 0);
		if(xpI.z == 6)
			return float3(vs_pos.x /  50, vs_pos.z /  50, 0);
		if(xpI.z == 7)
			return float3(vs_pos.x / 1000, vs_pos.z / 1000, 0);
		if(xpI.z == 8)
			return float3(frac(vs_pos.x), frac(vs_pos.z), 0);
	}

	else if(xpI.x == 4) {
		// float4x4 vsData = psi.vsData;
		// if(xpI.z == 1)
		// 	return vsData[xpI.z-1].xyz;
		// if(xpI.z == 2)
		// 	return vsData[xpI.z-1].xyz;
		// if(xpI.z == 3)
		// 	return vsData[xpI.z-1].xyz;
		// if(xpI.z == 4)
		// 	return vsData[xpI.z-1].xyz;
		// if(xpI.z == 5)
		// 	return vsData2[xpI.z-5];
		// if(xpI.z == 6)
		// 	return vsData2[xpI.z-5];
		// if(xpI.z == 7)
		// 	return vsData2[xpI.z-5];
		// if(xpI.z == 8)
		// 	return vsData2[xpI.z-5];
	}

	// color = lerp(color, mix2, .4);

	// if(chPos.x > 0 && chPos.x < 1)
	// 	color.r = 1;
	// if(chPos.y > 0 && chPos.y < 1)
	// 	color.g = 1;
	// if(chPos.z > 0 && chPos.z < 1)
	// 	color.b = 1;

	// if(pos.x > 0 && pos.x < .5 && pos.z > 0 && pos.z < .1)
	// 	return green;

	// color = (color * .5) + (float3(pos.xz, 0) * .5);
	// return pos;

	// return chunkNum.xyz;

	// color = lerp(color, green, circle(pos.xz, .2, .05));

	return color;
}

float3 HighlightSpawnArea(float3 diffuse, in PS_Input psi) {
	float4 colDanger = float4(1.0, 0.25, 0.0, 0.20);	// Color of Danger Zone at Night from 24 to 54 distance from camera
	float4 colLowLight = float4(0.75, 0.5, 0.0, 0.1);		// Color of Area with light level < 0.43
	float4 colRing = float4(0.0, 0.5, 1.0, 0.2);		// Color (0.3 size ring) of distance to begin/end Spawning Zone

	bool lowLight = false;
	float dist = length(psi.wPos);

	// This determines the inner/outer ring factor based on distance from camera
	float ringPct = max(
		step(24.0, dist) - smoothstep(24.0, 24.3, dist),
		smoothstep(53.5, 54.0, dist) - step(54.3, dist)
	);

	if( TEXTURE_1.Sample(TextureSampler1, float2(0,1)).r > .416){
		//day
		if(psi.uv1.x < 0.43 && psi.uv1.y < 0.438)
			lowLight = true;
	} else {
		//night
		if(psi.uv1.x < 0.43)
			lowLight = true;
	}

	// Set shade to colDanger if inside 24-54 (hard step range), otherwise colLowLight
	float4 shade = lerp(colLowLight, colDanger, (step(24.0, dist) - step(54.0, dist)) );

	// Alter the color by colDanger if lowLight is true (light level < .43 (8?)) and distance < 60
	diffuse.rgb = lerp(diffuse.rgb, shade.rgb, shade.a * float(lowLight) * (dist < 60));

	// Color the inner/outer rings of spawn area
	diffuse.rgb = lerp(diffuse.rgb, colRing.rgb, colRing.a * ringPct);

	return diffuse;
}

float3 HighlightChunkBoundary(float3 diffuse, in PS_Input psi) {
	// Parameters to chunk boundary highlighting
	float3 chPos = psi.chunkPosition;

	float3 edgeOffset = 0.000001;	// Offset from chunk edge to begin coloring
	float3 edgeWidth = 0.03;		// Offset from chunk edge to smoothstep to off
	float3 edgeRed = float3(.6, 0, 0);
	// float3 edgeGreen = float3(0, 1, 0);
	float3 edgeBlue = float3(0.2, 0.2, 1);

	float3  edgePct;
	float3 	distFade = smoothstep(24, 26, length(psi.wPos));
	// distFade = 0;

// ---- Close Chunk Boundary Highlight (0, 0) ----

	// 		   Start at edgeOffset			smoothstep from edgeOffset to edgeWidth
	edgePct = (1-step(edgeOffset, chPos)) + smoothstep(edgeOffset, edgeWidth, chPos );

	// lerp edgeColor to diffuse color based on edgePct, capped by distFade
	diffuse.rgb = lerp(edgeRed, diffuse.rgb, max(edgePct.x, distFade.x));		// Red / x
	// diffuse.rgb = lerp(edgeGreen, diffuse.rgb, max(edgePct.y, distFade.y));	// Green / y
	diffuse.rgb = lerp(edgeBlue, diffuse.rgb, max(edgePct.z, distFade.z));		// Blue / z


// ---- Far Chunk Boundary Highlight (16, 16) ----

	// float3 chMax = 16;

	// 			  Smoothstep at edge end										 stop just before chunk end
	// edgePct = (1-smoothstep(chMax - edgeWidth, chMax - edgeOffset, chPos )) + step(chMax - edgeOffset, chPos);

	// lerp edgeColor to diffuse color based on edgePct, capped by distFade
	// diffuse.rgb = lerp(edgeRed, diffuse.rgb, max(edgePct.x, distFade.x));
	// diffuse.rgb = lerp(edgeGreen, diffuse.rgb, max(edgePct.y, distFade.y));
	// diffuse.rgb = lerp(edgeBlue, diffuse.rgb, max(edgePct.z, distFade.z));


	// This original line (by Fizz, et al) causes x,y,z chunk coloring
	// diffuse.rgb = lerp(float3(1.0f, 1.0f, 1.0f), diffuse.rgb, smoothstep(0.0f, 2.0f, PSInput.chunkPosition * 16.0f));

	return diffuse;
}

ROOT_SIGNATURE
void main(in PS_Input PSInput, out PS_Output PSOutput)
{
#ifdef BYPASS_PIXEL_SHADER
    PSOutput.color = float4(0.0f, 0.0f, 0.0f, 0.0f);
    return;
#else

#if USE_TEXEL_AA
	float4 diffuse = texture2D_AA(TEXTURE_0, TextureSampler0, PSInput.uv0 );
#else
	float4 diffuse = TEXTURE_0.Sample(TextureSampler0, PSInput.uv0);
#endif

#ifdef SEASONS_FAR
	diffuse.a = 1.0f;
#endif

#if USE_ALPHA_TEST
	#ifdef ALPHA_TO_COVERAGE
		#define ALPHA_THRESHOLD 0.05
	#else
		#define ALPHA_THRESHOLD 0.5
	#endif
	if(diffuse.a < ALPHA_THRESHOLD)
		discard;
#endif

#if defined(BLEND)
	diffuse.a *= PSInput.color.a;
#endif

#if !defined(ALWAYS_LIT)
	diffuse = diffuse * TEXTURE_1.Sample(TextureSampler1, PSInput.uv1);
#endif

#ifndef SEASONS
	#if !USE_ALPHA_TEST && !defined(BLEND)
		diffuse.a = PSInput.color.a;
	#endif

	diffuse.rgb *= PSInput.color.rgb;
#else
	float2 uv = PSInput.color.xy;
	diffuse.rgb *= lerp(1.0f, TEXTURE_2.Sample(TextureSampler2, uv).rgb*2.0f, PSInput.color.b);
	diffuse.rgb *= PSInput.color.aaa;
	diffuse.a = 1.0f;
#endif

#if !defined(BLEND) && !defined(ALPHA_TEST)
	diffuse.rgb = HighlightSpawnArea(diffuse.rgb, PSInput);
#endif

#ifdef FOG
	diffuse.rgb = lerp( diffuse.rgb, PSInput.fogColor.rgb, PSInput.fogColor.a );
#endif

//
// ------ Chunk Boundary Highlighting ------
//
	diffuse.rgb = HighlightChunkBoundary(diffuse.rgb, PSInput);

	PSOutput.color = diffuse;

#ifdef VR_MODE
	// On Rift, the transition from 0 brightness to the lowest 8 bit value is abrupt, so clamp to
	// the lowest 8 bit value.
	PSOutput.color = max(PSOutput.color, 1 / 255.0f);
#endif

#endif // BYPASS_PIXEL_SHADER
}
