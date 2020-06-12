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
	float4 scol0 = float4(1.0, 0.25, 0.0, 0.5);	
	float4 scol1 = float4(0.75, 0.5, 0.0, 0.3);	
	float4 dcol = float4(0.0, 0.5, 1.0, 0.5);	
	bool sf = false;	
	float dist = length(PSInput.wPos);	
	float lf = max(step(24.,dist)-smoothstep(24.,24.3,dist),smoothstep(53.5,54.,dist)-step(54.,dist));	
	if( TEXTURE_1.Sample(TextureSampler1, float2(0,1)).r > .416){	
		//day	
		if(PSInput.uv1.y<0.438&&PSInput.uv1.x<0.43)sf = true;	
	}else{	
		//night	
		if(PSInput.uv1.x<0.43)sf = true;	
	}	
	scol0 = lerp(scol1,scol0,step(24.,dist)-step(54.,dist));	
	diffuse.rgb = lerp(diffuse.rgb,scol0.rgb,scol0.a*float(sf));	
	diffuse.rgb = lerp(diffuse.rgb,dcol.rgb,dcol.a*lf);	
#endif	
//=*=*=	


#ifdef FOG
	diffuse.rgb = lerp( diffuse.rgb, PSInput.fogColor.rgb, PSInput.fogColor.a );
#endif
	
	diffuse.rgb = lerp(float3(1.0f, 1.0f, 1.0f), diffuse.rgb, smoothstep(0.0f, 2.0f, PSInput.chunkPosition * 16.0f));
	PSOutput.color = diffuse;

#ifdef VR_MODE
	// On Rift, the transition from 0 brightness to the lowest 8 bit value is abrupt, so clamp to 
	// the lowest 8 bit value.
	PSOutput.color = max(PSOutput.color, 1 / 255.0f);
#endif

#endif // BYPASS_PIXEL_SHADER
}