#include "ShaderConstants.fxh"
#include "util.fxh"

#include "funcs/macros.hlsl"
#include "funcs/shapes.hlsl"
#include "funcs/util.hlsl"
#include "funcs/hud.hlsl"

/***

	TODO/IDEAS:
		☐ xyz reticule
		  - Learn about vector angles / angle math
		☐ Adjust for camera position when showing 5x5 diagonals / 10x10 + marks

	RESEARCH
		☐ Pass game data to shader
			? Item in hand
			? Options in menu
		☐ Additional key bindings?
		☐ Some way to pass data on to future frames?  Like ghost trails... (cool)

*/
struct PS_Input
{
	float3 chunkPosition : CHUNK_POS;		// Relative world coordinates?
	float4 position : SV_Position;			// Screen Coordinates
	float3 wPos : worldPos;					// Camera Coordinates

#ifndef BYPASS_PIXEL_SHADER
	lpfloat4 color : COLOR;
	float2 uv0 : TEXCOORD_0;
	float2 uv1 : TEXCOORD_1;				// x = blockLight, y = skyLight
	float4 cc : TEXCOORD_2;
#endif

#ifdef FOG
	float4 fogColor : FOG_COLOR;
#endif
};

struct PS_Output
{
	float4 color : SV_Target;
};

struct float3_grid {
	float3 _00, _01, _02, _03;
	float3 _10, _11, _12, _13;
	float3 _20, _21, _22, _23;
	float3 _30, _31, _32, _33;
	float3 _40, _41, _42, _43;
};

float3 testing_hud(float3 diffuse, in PS_Input psi) {
	float2 pos = psi.position.xy;

	float3_grid space;

	// Appears as though uv1.x == light level of pixel being rendered9
	// Appears as though uv1.y == 0 in nether and 239/255 in overworld (day/night)

	space._00 = space._01 = space._02 = space._03 =
	space._10 = space._11 = space._12 = space._13 =
	space._20 = space._21 = space._22 = space._23 =
	space._30 = space._31 = space._32 = space._33 =
	space._40 = space._41 = space._42 = space._43 = 0;

	// space._00 = FOG_COLOR.rgb;
	// space._01 = sin(psi.wPos * TIME / 10);
	// space._10 = luma601(diffuse);
	// space._11 = luma709(diffuse);
	// if(space._10.r < .3) {
	// 	#if !defined(ALWAYS_LIT)
#if USE_TEXEL_AA
			space._30 = texture2D_AA(TEXTURE_0, TextureSampler0, psi.uv0 );
#endif
	// 		space._31 = diffuse * TEXTURE_1.Sample(TextureSampler1, psi.uv1).rgb;
	// 	#endif
		// space._30 = AdjustLumosity(diffuse, .3);
		// space._31 = AdjustLumosity(diffuse, .5);
	// }
	// space._40 = psi.wPos;
	// space._41 = psi.chunkPosition;

 	// diffuse = hud_indicator(diffuse, pos, f2(-1,-1), rd3 * (space._01 == space._11));
	// diffuse = hud_indicator(diffuse, pos, f2( 0,-1), gr3 * (float)(psi.cc == FOG_COLOR));
	// diffuse = hud_indicator(diffuse, pos, f2( 1,-1), bu3 * (space._20 == space._01));
	// diffuse = hud_indicator(diffuse, pos, f2(-1, 0), cy3 * 0);
	// diffuse = hud_indicator(diffuse, pos, f2( 0, 0), ma3 * 0);
	// diffuse = hud_indicator(diffuse, pos, f2(-1, 0), yl3 * 0);
	diffuse = hud_indicator(diffuse, pos, f2( 3, 0), yl3 * (psi.uv1.y > .5));

	// diffuse = hud_space(diffuse, pos, f2(-2,  0), space._00);
	// diffuse = hud_space(diffuse, pos, f2(-2,  1), space._01);
	// diffuse = hud_space(diffuse, pos, f2(-1,  0), space._10);
	// diffuse = hud_space(diffuse, pos, f2(-1,  1), space._11);
	// diffuse = hud_space(diffuse, pos, f2( 1,  0), space._30);
	// diffuse = hud_space(diffuse, pos, f2( 1,  1), space._31);
	// diffuse = hud_space(diffuse, pos, f2( 2,  0), space._40);
	// diffuse = hud_space(diffuse, pos, f2( 2,  1), space._41);

	// diffuse = hud_space_huge(diffuse, pos, f2(-1, 0), f3(frac(psi.chunkPosition).x, 0, frac(psi.chunkPosition).z));
	// diffuse = hud_space_huge(diffuse, pos, f2( 0, 0), f3(frac(psi.chunkPosition).x, 0, frac(psi.chunkPosition).z));
	// diffuse = hud_space_huge(diffuse, pos, f2(-1,-1), f3(frac(psi.chunkPosition).x, 0, frac(psi.chunkPosition).z));
	// diffuse = hud_space_huge(diffuse, pos, f2( 0,-1), f3(frac(psi.chunkPosition).x, 0, frac(psi.chunkPosition).z));

	// diffuse = hud_grid(diffuse, pos, f2(0,0), f3(diffuse.r, 0, 0), 1, f2(530, 300), 200, 30);
	// diffuse = hud_grid(diffuse, pos, f2(1,0), f3(0, diffuse.g, 0), 1, f2(530, 300), 200, 30);
	// diffuse = hud_grid(diffuse, pos, f2(2,0), f3(0, 0, diffuse.b), 1, f2(530, 300), 200, 30);
	// diffuse = hud_grid(diffuse, pos, f2(1,1), 1-diffuse, 1, f2(530, 300), 200, 30);

	return diffuse;
}


// float3 testing_cubes(float3 color, in PS_Input psi) {

// 	// return color;

// 	float3 chFrac = frac(psi.chunkPosition);
// 	// Get our abs() of worldPos integer, adjusted by our fractional chunk position
// 	float3 wPosInt = ceil(psi.wPos - (chFrac * sign(psi.chunkPosition)));

// 	float q1 = 0, q2 = 0, q3 = 0, q4 = 0;



// 	float4 ts1 = TEXTURE_1.Sample(TextureSampler1, float2(.1,.1));//.r > .416){
// 	q1 = nether(FOG_COLOR.rgb); 	// psi.uv0.x;	// Red
// 	// q2 = between(ts1.r, .417, .7); 	// psi.uv0.y;	// Green
// 	// q3 = between(ts1.r, .701, .9); 	// psi.uv1.x;	// Blue
// 	// q4 = between(ts1.r, .901, 1); 	// psi.uv1.y;	// Cyan

// 	// q1 = q2 = q3 = q4 = 1;

// 	float4 colZero = float4(.5, .5, .5, .5);
// 	float4 colFive = float4(.5, 0, 0, .75);
// 	float4 colTen = float4(.5, 0, 0, .75);

// 	float3 sq1 = 0, sq2 = 0, sq3 = 0, sq4 = 0;

// 	sq1 = f3(1,0,0);	// Red
// 	sq2 = f3(0,1,0);	// Green
// 	sq3 = f3(0,0,1);	// Blue
// 	sq4 = f3(0,1,1);	// Cyan

// 	if(between(abs(wPosInt.x), 0, 5) && between(abs(wPosInt.z), 0, 5) && between(abs(wPosInt.y), 0, 50)) {

// 		color = lerp(color, sq1 * q1, rect(chFrac.xz * 2, f2(0.5,0.5), .30, .05));
// 		color = lerp(color, sq2 * q2, rect(chFrac.xz * 2, f2(0.5,1.5), .30, .05));
// 		color = lerp(color, sq3 * q3, rect(chFrac.xz * 2, f2(1.5,0.5), .30, .05));
// 		color = lerp(color, sq4 * q4, rect(chFrac.xz * 2, f2(1.5,1.5), .30, .05));

// 		// color = lerp(color, sq1 * q1, rect(chFrac.xy * 2, f2(0.5,0.5), .30, .05));
// 		// // color = lerp(color, HUEtoRGB(0), rect(chFrac.xy * 2, f2(0.5,0.5), .30, .05));
// 		// color = lerp(color, sq2 * q2, rect(chFrac.xy * 2, f2(0.5,1.5), .30, .05));
// 		// // color = lerp(color, HUEtoRGB(.5), rect(chFrac.xy * 2, f2(0.5,1.5), .30, .05));
// 		// color = lerp(color, sq3 * q3, rect(chFrac.xy * 2, f2(1.5,0.5), .30, .05));
// 		// color = lerp(color, sq4 * q4, rect(chFrac.xy * 2, f2(1.5,1.5), .30, .05));

// 		// color = lerp(color, sq1 * q1, rect(chFrac.yz * 2, f2(0.5,0.5), .30, .05));
// 		// color = lerp(color, sq2 * q2, rect(chFrac.yz * 2, f2(0.5,1.5), .30, .05));
// 		// color = lerp(color, sq3 * q3, rect(chFrac.yz * 2, f2(1.5,0.5), .30, .05));
// 		// color = lerp(color, sq4 * q4, rect(chFrac.yz * 2, f2(1.5,1.5), .30, .05));
// 	}

// 	return color;
// }

float3 DrawSunline(float3 diffuse, in PS_Input psi) {

	float3 colSunup = f3(1, 0.698, 0),
			colSunset = f3(.5, .349, 0);

	float3 chFrac = frac(psi.chunkPosition);
	// Get our abs() of worldPos integer, adjusted by our fractional chunk position
	float3 wPosInt = ceil(psi.wPos - (chFrac * sign(psi.chunkPosition)));

	// Only draw on east/west block (wPosIn.z) on the floor (chFrac.y) where our head is at (wPosInt.y + 1) (first person)
	if(wPosInt.z == 0 && chFrac.y == 0 && wPosInt.y + 1 == 0) {
		float  drawPct = 	( smoothstep(-1, 1, psi.wPos.x) - step(1, psi.wPos.x) )
						*	( smoothstep(0.49, 0.498, chFrac.z) - smoothstep(0.502, 0.51, chFrac.z) );

		float3 color = lerp(colSunset, colSunup, smoothstep(-1, 1, psi.wPos.x));

		diffuse = lerp(diffuse, color, 1.0 * drawPct);
	}

	return diffuse;
}

float3 HilightDistancePoints(float3 diffuse, in PS_Input psi) {

	float4 colZero = float4(.5, .5, .5, .5);
	float4 colFive = float4(.5, 0, 0, .75);
	float4 colTen = float4(.5, 0, 0, .75);

	float3 chFrac = frac(psi.chunkPosition);
	// Get our abs() of worldPos integer, adjusted by our fractional chunk position
	float3 wPosInt = abs(ceil(psi.wPos - (chFrac * sign(psi.chunkPosition))));

	// Get our abs() of worldPos integer, adjusted by our fractional chunk position
	// float3 wPosInt = abs(ceil(psi.chunkPosition / 16 + psi.wPos ));
	// Move y down by 2 to adjust for standing height
	// wPosInt.y -= 2;


	// Determine if pixels block position is at (0, 0), (5, 5), (0, 10) or (10, 0) from our current position
	bool distAtZero = chFrac.y == 0 && wPosInt.x == 0 && wPosInt.z == 0;
	bool distAtFive = chFrac.y == 0 && wPosInt.x == 5 && wPosInt.z == 5;
	bool distAtTen = chFrac.y == 0 && ( (wPosInt.x == 0 && wPosInt.z == 10) || (wPosInt.x == 10 && wPosInt.z == 0));

	if(distAtZero || distAtFive || distAtTen) {

		// Square at center of block
		float chHilight = rect(chFrac.xz, .5, .1, .02);

		if(distAtZero)
			diffuse = lerp(diffuse, colZero.rgb, chHilight * colZero.a);
		else if(distAtFive)
			diffuse = lerp(diffuse, colFive.rgb, chHilight * colFive.a);
		else if(distAtTen)
			diffuse = lerp(diffuse, colTen.rgb, chHilight * colTen.a);

	}

	return diffuse;
}

float3 HighlightSpawnArea(float3 diffuse, in PS_Input psi) {
	float4 colDanger = float4(1.0, 0.25, 0.0, 0.20);		// Color of Danger Zone at Night from 24 to 54 distance from camera
	float4 colLowLight = float4(0.75, 0.5, 0.0, 0.18);		// Color of Area with light level < 8/15
	float4 colRing = float4(0.0, 0.5, 1.0, 0.2);			// Color (0.3 size ring) of distance to begin/end Spawning Zone

	if(inNether(psi.uv1))
		return diffuse;

	bool lowLight = false;
	float dist = length(psi.wPos);

	// This determines the inner/outer ring factor based on distance from camera
	float ringPct = max(
		step(24.0, dist) - smoothstep(24.0, 24.3, dist),
		smoothstep(53.5, 54.0, dist) - step(54.3, dist)
	);

	float uvLow = 7.0/15.0;

	if( TEXTURE_1.Sample(TextureSampler1, float2(0,1)).r > .416){
		//day
		if(psi.uv1.x <= uvLow && psi.uv1.y < 0.438)
			lowLight = true;
	} else {
		//night
		if(psi.uv1.x <= uvLow)
			lowLight = true;
	}
	// Transition shade from VeryLowLight to LowLight based on light normal
	float4 shade = colLowLight;

	// Set shade to colDanger if inside 24-54 (hard step range), otherwise shade
	shade = lerp(shade, colDanger, (step(24.0, dist) - step(54.0, dist)) );

	// Alter the color by colDanger if lowLight is true (light level < .43 (8?)) and distance < 60
	diffuse.rgb = lerp(diffuse.rgb, shade.rgb, shade.a /* * stepBand */ * float(lowLight) * (dist < 60));

	// Color the inner/outer rings of spawn area
	diffuse.rgb = lerp(diffuse.rgb, colRing.rgb, colRing.a * ringPct);

	return diffuse;
}

float3 HighlightChunkBoundary(float3 diffuse, in PS_Input psi) {
	// Parameters to chunk boundary highlighting
	const float3 chPos = psi.chunkPosition;
	const float3 chFrac = frac(psi.chunkPosition);

	// const float3 edgeOffset = 0.001;	// Offset from chunk edge to begin coloring
	const float3 edgeWidth = 0.005;		// Offset from chunk edge to smoothstep to off
	const float3 edgeRed = float3(.6, 0, 0);
	// const float3 edgeGreen = float3(0, 1, 0);
	const float3 edgeBlue = float3(0.2, 0.2, 1);

	float3 	distFade = inv(smoothstep(16, 20, length(psi.wPos)));

// ---- Close Chunk Boundary Highlight (0, 0) ----
	float3 edge = inv(smoothstep(0, edgeWidth, psi.chunkPosition.xyz) - smoothstep(16 - edgeWidth, 16, psi.chunkPosition.xyz));
	float3 blEdge = inv(smoothstep(0, edgeWidth, chFrac) - smoothstep(inv(edgeWidth), 1, chFrac));

	diffuse = lerp(diffuse, edgeRed, .75 * (edge.x * (blEdge.z + blEdge.y) * distFade.x));
	// diffuse = lerp(diffuse, edgeGreen, (edge.y * (blEdge.x + blEdge.z) * distFade.y));
	diffuse = lerp(diffuse, edgeBlue, .75 * (edge.z * (blEdge.x + blEdge.y) * distFade.z));

	// This original line (by Fizz, et al) causes x,y,z chunk coloring
	// diffuse.rgb = lerp(float3(1.0f, 1.0f, 1.0f), diffuse.rgb, smoothstep(0.0f, 2.0f, PSInput.chunkPosition * 16.0f));

	return diffuse;
}


ROOT_SIGNATURE
void main(in PS_Input PSInput, out PS_Output PSOutput) {

#ifdef BYPASS_PIXEL_SHADER
	PSOutput.color = 0.0;
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
	float	nearPct = easeOutCubic(smoothstep(0, 6, length(PSInput.wPos)));
	float3 darkenBy = TEXTURE_1.Sample(TextureSampler1, PSInput.uv1).rgb * 1.2;

	// Reduce light reduction nearby the player
	diffuse.rgb *= lerp(max(darkenBy, .8), darkenBy, nearPct);

	// Add Torch light color nearby
	diffuse.rgb += f3(.1, .05, 0) * (1-nearPct);
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


#ifdef FOG
	diffuse.rgb = lerp( diffuse.rgb, PSInput.fogColor.rgb, PSInput.fogColor.a * .60 );
#endif

#if !defined(BLEND) && !defined(ALPHA_TEST)
	diffuse.rgb = HighlightSpawnArea(diffuse.rgb, PSInput);
#endif

//
// ------ Chunk Boundary Highlighting ------
//
	diffuse.rgb = HighlightChunkBoundary(diffuse.rgb, PSInput);

	diffuse.rgb = HilightDistancePoints(diffuse.rgb, PSInput);

	// diffuse.rgb = testing_hud(diffuse.rgb, PSInput);
	// diffuse.rgb = testing_cubes(diffuse.rgb, PSInput);
	// diffuse.rgb = testing(diffuse.rgb, PSInput);

	diffuse.rgb = DrawSunline(diffuse.rgb, PSInput);

	PSOutput.color = diffuse;

#ifdef VR_MODE
	// On Rift, the transition from 0 brightness to the lowest 8 bit value is abrupt, so clamp to
	// the lowest 8 bit value
	PSOutput.color = max(PSOutput.color, 1 / 255.0f);
#endif

#endif // BYPASS_PIXEL_SHADER
}
