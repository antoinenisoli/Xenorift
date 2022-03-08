// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PhaseTravel/Toon"
{
	Properties
	{
		_Detail("Detail", Range( 0 , 1)) = 0
		_Strength("Strength", Range( 0 , 1)) = 0.5
		_Brightness("Brightness", Range( 0 , 1)) = 0
		_ColorMap("ColorMap", 2D) = "white" {}
		_Tint("Tint", Color) = (1,1,1,1)
		_SpecularIntensity("SpecularIntensity", Float) = 50
		_SpecularColor("SpecularColor", Color) = (1,1,1,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _ColorMap;
		uniform float4 _ColorMap_ST;
		uniform float4 _SpecularColor;
		uniform float _SpecularIntensity;
		uniform float _Brightness;
		uniform float4 _Tint;
		uniform float _Strength;
		uniform float _Detail;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 uv0_ColorMap = i.uv_texcoord * _ColorMap_ST.xy + _ColorMap_ST.zw;
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float dotResult3 = dot( ase_normWorldNormal , _WorldSpaceLightPos0.xyz );
			float temp_output_6_0 = max( 0.0 , dotResult3 );
			float smoothstepResult38 = smoothstep( 0.0 , 0.75 , temp_output_6_0);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 normalizeResult26 = normalize( ( ase_worldViewDir + _WorldSpaceLightPos0.xyz ) );
			float dotResult28 = dot( normalizeResult26 , ase_normWorldNormal );
			float smoothstepResult29 = smoothstep( 0.005 , 0.01 , pow( ( smoothstepResult38 * dotResult28 ) , pow( _SpecularIntensity , 2.0 ) ));
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			c.rgb = ( tex2D( _ColorMap, uv0_ColorMap ) * ( ( _SpecularColor * smoothstepResult29 ) + ( _Brightness + ( _Tint * float4( ( ( _Strength * ( floor( ( temp_output_6_0 / _Detail ) ) * ase_lightAtten ) ) * ase_lightColor.rgb ) , 0.0 ) ) ) ) ).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17700
-1931;52;1920;1050;4475.516;1307.995;3.690514;True;True
Node;AmplifyShaderEditor.CommentaryNode;22;-2464.786,565.4276;Inherit;False;977;390.0001;Toon;7;4;5;3;6;8;9;7;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;4;-2364.786,615.4276;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightPos;5;-2414.786,820.4276;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;27;-2354.596,-407.2034;Inherit;False;665.8191;286.8318;HalfView;3;24;25;26;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;3;-2043.786,711.4276;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;25;-2304.596,-357.2034;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMaxOpNode;6;-1899.786,709.4276;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-2044.786,811.4276;Inherit;False;Property;_Detail;Detail;0;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;24;-2035.368,-255.3716;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;8;-1762.786,709.4276;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;7;-1637.786,708.4276;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;36;-1695.302,1015.934;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;26;-1863.777,-253.5846;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1446.549,598.9488;Inherit;False;Property;_Strength;Strength;1;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;28;-1358.273,-253.4287;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;38;-1401.073,-495.242;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.75;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-1285.662,-28.5741;Inherit;False;Property;_SpecularIntensity;SpecularIntensity;5;0;Create;True;0;0;False;0;50;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-1437.101,840.0941;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;32;-1079.662,-51.5741;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;42;-1038.073,956.6914;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-1173.577,-295.7734;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-1109.556,672.7289;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;17;-1098.113,491.7331;Inherit;False;Property;_Tint;Tint;4;0;Create;True;0;0;False;0;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-924.1973,789.0939;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;30;-977.51,-235.7432;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-799.2097,517.9697;Inherit;False;Property;_Brightness;Brightness;2;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-748.183,638.1664;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;29;-719.8351,-237.374;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.005;False;2;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;34;-732.4248,-479.291;Inherit;False;Property;_SpecularColor;SpecularColor;6;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;12;-2027.709,150.6655;Inherit;True;Property;_ColorMap;ColorMap;3;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;13;-2019.49,348.3801;Inherit;False;0;12;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-482.8692,596.5872;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-431.4248,-340.291;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;33;-277.5842,240.3257;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;11;-1782.49,266.38;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;4.16119,112.557;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;2;541.7539,-144.2222;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Plantasia/Toon;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;0;4;0
WireConnection;3;1;5;1
WireConnection;6;1;3;0
WireConnection;24;0;25;0
WireConnection;24;1;5;1
WireConnection;8;0;6;0
WireConnection;8;1;9;0
WireConnection;7;0;8;0
WireConnection;26;0;24;0
WireConnection;28;0;26;0
WireConnection;28;1;4;0
WireConnection;38;0;6;0
WireConnection;37;0;7;0
WireConnection;37;1;36;0
WireConnection;32;0;31;0
WireConnection;39;0;38;0
WireConnection;39;1;28;0
WireConnection;16;0;15;0
WireConnection;16;1;37;0
WireConnection;41;0;16;0
WireConnection;41;1;42;1
WireConnection;30;0;39;0
WireConnection;30;1;32;0
WireConnection;18;0;17;0
WireConnection;18;1;41;0
WireConnection;29;0;30;0
WireConnection;21;0;20;0
WireConnection;21;1;18;0
WireConnection;35;0;34;0
WireConnection;35;1;29;0
WireConnection;33;0;35;0
WireConnection;33;1;21;0
WireConnection;11;0;12;0
WireConnection;11;1;13;0
WireConnection;14;0;11;0
WireConnection;14;1;33;0
WireConnection;2;13;14;0
ASEEND*/
//CHKSM=9BDCBD88304FBFA17493DC8322A5AFD951A248C5