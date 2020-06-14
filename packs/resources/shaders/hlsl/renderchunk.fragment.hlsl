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

	//=*=mob-spawn-area rendering=*=
#if !defined(BLEND) && !defined(ALPHA_TEST)
	float4 scol0 = float4(1.0, 0.25, 0.0, 0.20);		// Color of Danger Zone at Night from 24 to 54 distance from camera
	float4 scol1 = float4(0.75, 0.5, 0.0, 0.1);		// Color of Area outside of Danger Zone at Night & with light level < 0.43
	float4 dcol = float4(0.0, 0.5, 1.0, 0.2);		// Color (0.3 size ring) of distance to Danger Zone

	bool sf = false;
	float dist = length(PSInput.wPos);

	// This determines the inner/outer ring factor based on distance from camera
	float lf = max(
		step(24.0, dist) - smoothstep(24.0, 24.3, dist),
		smoothstep(53.5, 54.0, dist) - step(54.3, dist)
	);

	if( TEXTURE_1.Sample(TextureSampler1, float2(0,1)).r > .416){
		//day
		if(PSInput.uv1.y < 0.438 && PSInput.uv1.x < 0.43)
			sf = true;
	} else {
		//night
		if(PSInput.uv1.x < 0.43)
			sf = true;
	}

	// Set scol0 to scol1 if outside 24-54 (hard step)
	scol0 = lerp(scol1, scol0, (step(24.0, dist) - step(54.0, dist)) );

	// Alter the color by scol0 if sf is true (light level < .43 (8?))
	diffuse.rgb = lerp(diffuse.rgb, scol0.rgb, scol0.a * float(sf) * (dist < 60));

	// Alter the color by dcol if within the small inner/outer rings of danger zone
	diffuse.rgb = lerp(diffuse.rgb, dcol.rgb, dcol.a * lf);
#endif
//=*=*=


#ifdef FOG
	diffuse.rgb = lerp( diffuse.rgb, PSInput.fogColor.rgb, PSInput.fogColor.a );
#endif


//
// ------ Chunk Boundary Highlighting ------
//
	// Parameters to chunk boundary highlighting
	float3 chPos = PSInput.chunkPosition;

	float3 edgeOffset = 0.000001;	// Offset from chunk edge to begin coloring
	float3 edgeWidth = 0.03;		// Offset from chunk edge to smoothstep to off
	float3 edgeRed = float3(.5, 0, 0);
	// float3 edgeGreen = float3(0, 1, 0);
	float3 edgeBlue = float3(0.2, 0.2, 1);

	float3  edgePct;
	float3 	distFade = smoothstep(24, 26, dist);

	// 			Start at edgeOffset					smoothstep from edgeOffset to edgeWidth
	edgePct = (1-step(edgeOffset, chPos)) + smoothstep(edgeOffset, edgeWidth, chPos );

	// lerp edgeCol to diffuse based on edgePct, capped by distFade
	diffuse.rgb = lerp(edgeRed, diffuse.rgb, max(edgePct.x, distFade.x));		// Red / x
	// diffuse.rgb = lerp(edgeGreen, diffuse.rgb, max(edgePct.y, distFade.y));	// Green / y
	diffuse.rgb = lerp(edgeBlue, diffuse.rgb, max(edgePct.z, distFade.z));		// Blue / z

	float3 chMax = 16;
	// lerp edgeCol to diffuse from edgeWidth to chunk end
	// 			Smoothstep at edge end														stop just before chunk end
	// edgePct = (1-smoothstep(chMax - edgeWidth, chMax - edgeOffset, chPos )) + step(chMax - edgeOffset, chPos);
	// diffuse.rgb = lerp(edgeRed, diffuse.rgb, max(edgePct.xxx, distFade.xxx));
	// diffuse.rgb = lerp(edgeBlue, diffuse.rgb, max(edgePct.zzz, distFade.zzz));

	// This original line causes x,y,z chunk coloring
	// diffuse.rgb = lerp(float3(1.0f, 1.0f, 1.0f), diffuse.rgb, smoothstep(0.0f, 2.0f, PSInput.chunkPosition * 16.0f));


	PSOutput.color = diffuse;

#ifdef VR_MODE
	// On Rift, the transition from 0 brightness to the lowest 8 bit value is abrupt, so clamp to
	// the lowest 8 bit value.
	PSOutput.color = max(PSOutput.color, 1 / 255.0f);
#endif

#endif // BYPASS_PIXEL_SHADER
}
