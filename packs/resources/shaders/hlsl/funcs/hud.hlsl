#if !defined(_HUD_HLSL)
#define _HUD_HLSL

#include "funcs/macros.hlsl"
#include "funcs/shapes.hlsl"


float3 hud_grid(float3 diffuse, float2 pos, float2 xy, float3 color, float3 edgeColor, float2 topleft, float2 size, float2 margin) {
	size /= 2; // Size is actually used as center offset, so divide by 2

	topleft += size / 2;	// Offset the specified top-left by one size measure to account for center specified

	float2 center = topleft + size*xy*2 + size/2 + margin*xy;

	diffuse = lerp(diffuse, edgeColor, rect(pos, center, size+1));
	diffuse = lerp(diffuse, color, rect(pos, center, size));

	return diffuse;
}

float3 hud_indicator(float3 diffuse, float2 pos, float2 xy, float3 color, float3 edgeColor = 1) {
	const float2 screen = f2(1920, 1080 - 75); // Screen resolution - top/bottom chrome of ~120
	const float2 gridSize = f2(16, 4);	// 16 colums by 4 rows

	const float2 size = 15;	// pixels
	const float2 margin = 10; // pixels
	const float2 topleft = float2(
		screen.x / 2 - (size + margin).x * gridSize.x / 2 + margin.x / 2,	// center
		(screen.y - (size + margin).y * gridSize.y - margin.y) - 50			// bottom - (hotbar)
	); // center-bottom in pixels

	xy += floor(gridSize / 2);	// Center-offset grid xy position

	return hud_grid(diffuse, pos, xy, color, edgeColor, topleft, size, margin);
}

float3 hud_space(float3 diffuse, float2 pos, float2 xy, float3 color, float3 edgeColor = float3(1,1,1)) {
	const float2 screen = f2(1920, 1080 - 75); // Screen resolution - top/bottom chrome of ~120
	const float2 gridSize = f2(7, 7);	// 7 colums by 7 rows

	const float2 size = 100;		// pixels
	const float2 margin = 15; 	// pixels
	const float2 topleft = screen / 2 - (size + margin) * gridSize / 2 + margin / 2; // center-center in screen pixels

	xy += floor(gridSize / 2);	// Center-offset grid xy position

	return hud_grid(diffuse, pos, xy, color, edgeColor, topleft, size, margin);
}

float3 hud_space_huge(float3 diffuse, float2 pos, float2 xy, float3 color, float3 edgeColor = float3(1,1,1)) {
	const float2 screen = f2(1920, 1080 - 75); // Screen resolution - top/bottom chrome of ~120
	const float2 gridSize = f2(2, 2);	// 2 colums by 2 rows

	const float2 size = 200;	// pixels
	const float2 margin = 25; 	// pixels
	const float2 topleft = float2(margin.x,		// left
		(screen.y - (size + margin).y * gridSize.y - margin.y) 				// bottom
	); // pixels	left-bottom

	xy += floor(gridSize / 2);	// Center-offset grid xy position

	return hud_grid(diffuse, pos, xy, color, edgeColor, topleft, size, margin);
}

#endif	// _HUD_HLSL
