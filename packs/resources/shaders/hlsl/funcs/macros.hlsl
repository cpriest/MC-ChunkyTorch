#if !defined(_MACROS_HLSL)
#define _MACROS_HLSL

#define rd3 float3(1.0, 0.0, 0.0)
#define gr3 float3(0.0, 1.0, 0.0)
#define bu3 float3(0.0, 0.0, 1.0)
#define ma3 float3(1.0, 0.0, 1.0)
#define yl3 float3(1.0, 1.0, 0.0)
#define wh3 float3(1.0, 1.0, 1.0)
#define bk3 float3(0.0, 0.0, 0.0)
#define cy3 float3(0.5, 0.5, 1.0)

#define f2 float2
#define f3 float3
#define f4 float4


//	Overworld Fog Colors
//	default			#ABD2FF  #ABD2FF = float3(171, 210, 255)

//	Nether Fog Colors
//	warped_forest	#1a051A  #1a051A = float3(26, 5, 26)
//	crimson_forest	#330303  #330303 = float3(51, 3, 3)
//	soulsand_valley	#1B4745  #1B4745 = float3(27, 71, 69)
//	basalt_deltas	#685f70  #685f70 = float3(104, 95, 112)
//	hell			#330808  #330808 = float3(51, 8, 8)
//	the_end			#0B080C  #0B080C = float3(11, 8, 12)


//	Overworld Fog Colors
#define FOG_default			float3(171/255.0, 210/255.0, 255/255.0)

//	Nether Fog Colors
#define FOG_warped_forest	float3(26/255.0, 5/255.0, 26/255.0)
#define FOG_crimson_forest	float3(51/255.0, 3/255.0, 3/255.0)
#define FOG_soulsand_valley	float3(27/255.0, 71/255.0, 69/255.0)
#define FOG_basalt_deltas	float3(104/255.0, 95/255.0, 112/255.0)
#define FOG_hell			float3(51/255.0, 8/255.0, 8/255.0)
#define FOG_the_end			float3(11/255.0, 8/255.0, 12/255.0)


#define between(var, low, high) ((var) >= low && (var) <= high)
#define inv(x) (1-(x))

#endif	// _MACROS_HLSL
