// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "CosmicHell/R&D/CH_Enviro_V1"
{
	Properties
	{
		[SingleLineTexture][Header(Main Maps)][Space(15)]_Albedo("Albedo", 2D) = "white" {}
		[SingleLineTexture]_NormalMap("Normal Map", 2D) = "bump" {}
		[SingleLineTexture]_ThresholdMapRCellGShadow("Threshold Map (R = Cell G = Shadow)", 2D) = "white" {}
		[IntRange]_CellThreshold("Cell Threshold", Range( 0 , 10)) = 1.348499
		_LightingColorweight("Lighting Color weight", Range( 0 , 1)) = 0.7860179
		[Header(HSV Shadow)][Space(15)]_Hue("Hue", Range( -1 , 1)) = 0
		_Saturation("Saturation", Range( -1 , 1)) = 0
		_Value("Value", Range( -1 , 1)) = 0
		[Header(Shadow)][Space(15)]_Shadow_Threshold("Shadow_Threshold", Range( 0 , 1)) = 0.5
		_ShadowAmbient("ShadowAmbient", Range( 0 , 1)) = 0.2782227
		_AO_Threshold("AO_Threshold", Range( 0 , 1)) = 0.6661413
		_AO_LightInput("AO_LightInput", Range( 0 , 1)) = 1
		_FresnelShadow("Fresnel Shadow", Range( 0 , 1)) = 0.2085736
		[Header(HSV Spec)][Space(15)]_HueSpec("Hue", Range( -1 , 1)) = -1
		_SaturationSpec("Saturation", Range( -1 , 1)) = 0
		_ValueSpec("Value", Range( -1 , 1)) = 0.6475888
		_SpecPow("SpecPow", Range( 1 , 100)) = 9.676549
		_NormalScale("Normal Scale", Float) = 1
		[Toggle(_DEBUG_ON)] _Debug("Debug", Float) = 0
		_ShadowCOlor("Shadow COlor", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _DEBUG_ON
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
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

		uniform float4 _ShadowCOlor;
		uniform sampler2D _Albedo;
		uniform float _Hue;
		uniform float _Saturation;
		uniform float _Value;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _NormalScale;
		uniform sampler2D _ThresholdMapRCellGShadow;
		uniform float _CellThreshold;
		uniform float _HueSpec;
		uniform float _SaturationSpec;
		uniform float _ValueSpec;
		uniform float _SpecPow;
		uniform float _FresnelShadow;
		uniform float _AO_LightInput;
		uniform float _AO_Threshold;
		uniform float _ShadowAmbient;
		uniform float _LightingColorweight;
		uniform float _Shadow_Threshold;


		float3 HSVToRGB( float3 c )
		{
			float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}


		float3 RGBToHSV(float3 c)
		{
			float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
			float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
			float d = q.x - min( q.w, q.y );
			float e = 1.0e-10;
			return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

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
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 tex2DNode126 = tex2D( _Albedo, i.uv_texcoord );
			float3 hsvTorgb155 = RGBToHSV( tex2DNode126.rgb );
			float3 hsvTorgb156 = HSVToRGB( float3(saturate( ( hsvTorgb155.x + _Hue ) ),saturate( ( hsvTorgb155.y + _Saturation ) ),saturate( ( hsvTorgb155.z + _Value ) )) );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 tex2DNode314 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalScale );
			float3 WorldNormal183 = (WorldNormalVector( i , tex2DNode314 ));
			float dotResult132 = dot( ase_worldlightDir , WorldNormal183 );
			float NDotL206 = dotResult132;
			float temp_output_348_0 = saturate( ase_lightAtten );
			float temp_output_200_0 = ( saturate( NDotL206 ) * temp_output_348_0 );
			float4 tex2DNode148 = tex2D( _ThresholdMapRCellGShadow, i.uv_texcoord );
			float temp_output_300_0 = ( temp_output_200_0 - pow( tex2DNode148.r , _CellThreshold ) );
			float4 lerpResult157 = lerp( float4( hsvTorgb156 , 0.0 ) , tex2DNode126 , ( 1.0 - saturate( step( temp_output_300_0 , 0.0 ) ) ));
			float3 hsvTorgb264 = RGBToHSV( tex2DNode126.rgb );
			float3 hsvTorgb272 = HSVToRGB( float3(saturate( ( hsvTorgb264.x + _HueSpec ) ),saturate( ( hsvTorgb264.y + _SaturationSpec ) ),saturate( ( hsvTorgb264.z + _ValueSpec ) )) );
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 normalizeResult276 = normalize( ( ase_worldlightDir + ase_worldViewDir ) );
			float3 HalfView278 = normalizeResult276;
			float dotResult282 = dot( WorldNormal183 , HalfView278 );
			float CellNoFilter337 = temp_output_300_0;
			float4 lerpResult288 = lerp( lerpResult157 , float4( hsvTorgb272 , 0.0 ) , ( 1.0 - step( ( saturate( pow( saturate( dotResult282 ) , _SpecPow ) ) - ( 1.0 - saturate( CellNoFilter337 ) ) ) , 0.5 ) ));
			float dotResult186 = dot( ase_worldViewDir , WorldNormal183 );
			float NdotV208 = dotResult186;
			float4 lerpResult403 = lerp( _ShadowCOlor , lerpResult288 , ( ( 1.0 - step( saturate( NdotV208 ) , _FresnelShadow ) ) * ( 1.0 - step( ( (0.0 + (temp_output_200_0 - 0.0) * (_AO_LightInput - 0.0) / (1.0 - 0.0)) + tex2DNode148.g ) , _AO_Threshold ) ) ));
			float4 lerpResult204 = lerp( ( ase_lightColor * lerpResult403 ) , lerpResult403 , _LightingColorweight);
			#ifdef _DEBUG_ON
				float4 staticSwitch383 = float4( 0,0,0,0 );
			#else
				float4 staticSwitch383 = ( lerpResult204 * ( 1.0 - saturate( step( saturate( ( (0.0 + (NDotL206 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) * temp_output_348_0 ) ) , _Shadow_Threshold ) ) ) );
			#endif
			c.rgb = staticSwitch383.rgb;
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
			o.Normal = float3(0,0,1);
			float4 tex2DNode126 = tex2D( _Albedo, i.uv_texcoord );
			float3 hsvTorgb155 = RGBToHSV( tex2DNode126.rgb );
			float3 hsvTorgb156 = HSVToRGB( float3(saturate( ( hsvTorgb155.x + _Hue ) ),saturate( ( hsvTorgb155.y + _Saturation ) ),saturate( ( hsvTorgb155.z + _Value ) )) );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 tex2DNode314 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalScale );
			float3 WorldNormal183 = (WorldNormalVector( i , tex2DNode314 ));
			float dotResult132 = dot( ase_worldlightDir , WorldNormal183 );
			float NDotL206 = dotResult132;
			float temp_output_348_0 = saturate( 1 );
			float temp_output_200_0 = ( saturate( NDotL206 ) * temp_output_348_0 );
			float4 tex2DNode148 = tex2D( _ThresholdMapRCellGShadow, i.uv_texcoord );
			float temp_output_300_0 = ( temp_output_200_0 - pow( tex2DNode148.r , _CellThreshold ) );
			float4 lerpResult157 = lerp( float4( hsvTorgb156 , 0.0 ) , tex2DNode126 , ( 1.0 - saturate( step( temp_output_300_0 , 0.0 ) ) ));
			float3 hsvTorgb264 = RGBToHSV( tex2DNode126.rgb );
			float3 hsvTorgb272 = HSVToRGB( float3(saturate( ( hsvTorgb264.x + _HueSpec ) ),saturate( ( hsvTorgb264.y + _SaturationSpec ) ),saturate( ( hsvTorgb264.z + _ValueSpec ) )) );
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 normalizeResult276 = normalize( ( ase_worldlightDir + ase_worldViewDir ) );
			float3 HalfView278 = normalizeResult276;
			float dotResult282 = dot( WorldNormal183 , HalfView278 );
			float CellNoFilter337 = temp_output_300_0;
			float4 lerpResult288 = lerp( lerpResult157 , float4( hsvTorgb272 , 0.0 ) , ( 1.0 - step( ( saturate( pow( saturate( dotResult282 ) , _SpecPow ) ) - ( 1.0 - saturate( CellNoFilter337 ) ) ) , 0.5 ) ));
			float dotResult186 = dot( ase_worldViewDir , WorldNormal183 );
			float NdotV208 = dotResult186;
			float4 lerpResult403 = lerp( _ShadowCOlor , lerpResult288 , ( ( 1.0 - step( saturate( NdotV208 ) , _FresnelShadow ) ) * ( 1.0 - step( ( (0.0 + (temp_output_200_0 - 0.0) * (_AO_LightInput - 0.0) / (1.0 - 0.0)) + tex2DNode148.g ) , _AO_Threshold ) ) ));
			float4 temp_output_356_0 = ( lerpResult403 * _ShadowAmbient );
			#ifdef _DEBUG_ON
				float4 staticSwitch382 = float4( 0,0,0,0 );
			#else
				float4 staticSwitch382 = temp_output_356_0;
			#endif
			o.Emission = staticSwitch382.rgb;
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
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
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
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
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
Version=18800
28;357;1325;745;-4036.581;-852.4117;1.651251;True;False
Node;AmplifyShaderEditor.RangedFloatNode;315;-1096.106,609.9106;Inherit;False;Property;_NormalScale;Normal Scale;18;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;314;-787.5122,559.9495;Inherit;True;Property;_NormalMap;Normal Map;1;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;71f8c3c168959e3489c6fd33f3402f1e;3ce9312a13ea2194289c60a5e0b7a89d;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;133;-369.4031,561.7445;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;183;-65.81166,558.355;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;131;-809.4396,125.797;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;184;-783.3925,272.9905;Inherit;False;183;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;277;-1306.419,3956.799;Inherit;False;1034.451;381.4189;HalfView;5;278;274;276;275;273;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;132;-442.0569,179.9494;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;273;-1221.077,4161.799;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;274;-1263.419,4023.561;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;206;-36.02954,164.1188;Inherit;False;NDotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;182;2342.208,450.2069;Inherit;False;1421.881;608.2914;Cell;8;153;152;134;144;135;200;300;337;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;129;1526.765,1679.873;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;275;-960.8811,4059.163;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;207;927.1783,185.68;Inherit;False;206;NDotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;147;1498.95,878.3152;Inherit;True;Property;_ThresholdMapRCellGShadow;Threshold Map (R = Cell G = Shadow);2;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;27c4d73d01a535645b616213aa842a5a;a58718a0f91d5974cb89c5d40b5d385f;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.LightAttenuation;198;1688.075,492.5429;Inherit;True;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;153;2325.423,854.8844;Inherit;False;Property;_CellThreshold;Cell Threshold;3;1;[IntRange];Create;True;0;0;0;False;0;False;1.348499;1.348499;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;143;1664.495,186.8112;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;148;1853.736,876.3846;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;276;-758.4187,4061.561;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;348;1952.304,495.3904;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;152;2600.092,903.5641;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;278;-542.2968,4060.285;Inherit;False;HalfView;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;200;2377.428,494.7634;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;300;2745.843,512.0724;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;281;410.955,3971.894;Inherit;False;183;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;279;431.8975,4052.302;Inherit;False;278;HalfView;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;188;-625.6299,-277.4166;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;282;714.1743,3996.237;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;127;1417.88,1434.835;Inherit;True;Property;_Albedo;Albedo;0;1;[SingleLineTexture];Create;True;0;0;0;False;2;Header(Main Maps);Space(15);False;af520b8dea87bd24dbfd9c7e36b41b11;9182448b83330aa4a998a5a5e19b0c0f;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;337;3070.504,764.7732;Inherit;False;CellNoFilter;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;187;-633.3996,-110.3681;Inherit;False;183;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;186;-365.0219,-246.1448;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;283;941.2842,3998.274;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;126;2029.865,1438.073;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;292;820.1805,4228.113;Inherit;False;Property;_SpecPow;SpecPow;17;0;Create;True;0;0;0;False;0;False;9.676549;34.9;1;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;210;2138.828,-741.4634;Inherit;False;1539.115;341.3201;AO_Shadow;6;180;172;171;179;178;177;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;303;1244.155,4339.526;Inherit;True;337;CellNoFilter;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;181;2372.122,1785.517;Inherit;False;1482.393;588.3171;Shadow Color;11;155;156;163;161;164;158;166;160;159;168;167;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RGBToHSVNode;155;2422.122,2003.032;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;180;2188.828,-586.137;Inherit;False;Property;_AO_LightInput;AO_LightInput;11;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;208;-64.69812,-201.2535;Inherit;False;NdotV;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;197;2359.824,-1198.18;Inherit;False;1353.797;367.3293;FresnelShadow;5;191;190;189;192;209;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;163;2644.896,1922.529;Inherit;False;Property;_Saturation;Saturation;6;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;164;2645.384,2000.611;Inherit;False;Property;_Value;Value;7;0;Create;True;0;0;0;False;0;False;0;0.4122968;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;284;1125.174,3992.237;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;12.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;306;1453.064,4318.421;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;161;2634.327,1835.517;Inherit;False;Property;_Hue;Hue;5;0;Create;True;0;0;0;False;2;Header(HSV Shadow);Space(15);False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;261;2341.408,2495.342;Inherit;False;1482.393;588.3171;Shadow Color;11;272;271;270;269;268;267;266;265;264;263;262;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RGBToHSVNode;264;2391.408,2712.857;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;209;2548.936,-1087.502;Inherit;True;208;NdotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;179;2508.179,-664.5571;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;134;3061.821,524.9175;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;307;1624.978,4313.149;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;158;3052.855,2031.102;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;263;2614.182,2632.354;Inherit;False;Property;_SaturationSpec;Saturation;15;0;Create;False;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;265;2614.67,2711.935;Inherit;False;Property;_ValueSpec;Value;16;0;Create;False;0;0;0;False;0;False;0.6475888;0.6475888;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;160;3061,2238.834;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;159;3059.318,2132.761;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;286;1447.022,3985.687;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;262;2603.613,2545.342;Inherit;False;Property;_HueSpec;Hue;14;0;Create;False;0;0;0;False;2;Header(HSV Spec);Space(15);False;-1;-1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;191;2916.423,-1081.836;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;178;2980.974,-636.4559;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;190;2836.695,-946.8514;Inherit;False;Property;_FresnelShadow;Fresnel Shadow;12;0;Create;True;0;0;0;False;0;False;0.2085736;0.375;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;172;2231.628,-672.7682;Inherit;False;Property;_AO_Threshold;AO_Threshold;10;0;Create;True;0;0;0;False;0;False;0.6661413;0.6661413;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;175;2090.06,-313.924;Inherit;False;1919.919;544.87;Shadow;7;138;145;139;170;169;333;201;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;268;3022.141,2740.927;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;166;3191.201,2029.297;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;144;3294.209,531.3458;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;266;3028.604,2842.586;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;305;1875.99,4026.423;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;267;3030.286,2948.659;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;168;3198.24,2257.729;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;167;3194.24,2125.729;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;270;3167.526,2967.554;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;285;2212.961,3983.488;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;189;3168.324,-1098.313;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;171;3259.321,-673.776;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;156;3616.515,2039.323;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TFHCRemapNode;169;2116.694,-225.8525;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;271;3160.487,2739.122;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;269;3163.526,2835.554;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;135;3566.09,525.5297;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;201;2424.516,-112.0611;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;272;3585.801,2749.148;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;287;2530.756,3985.455;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;192;3534.622,-1094.528;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;177;3498.943,-628.8842;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;157;3852.76,1390.079;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;170;2743.943,101.1334;Inherit;False;Property;_Shadow_Threshold;Shadow_Threshold;8;0;Create;True;0;0;0;False;2;Header(Shadow);Space(15);False;0.5;0.647;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;333;2816.689,-224.7851;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;288;4235.193,1384.444;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;194;4330.289,-861.1122;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;404;4290.873,1681.34;Inherit;False;Property;_ShadowCOlor;Shadow COlor;20;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;403;4598.005,1583.916;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;199;4612.084,974.9456;Inherit;True;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.StepOpNode;138;3060.406,11.74025;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;145;3297.72,-25.17644;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;202;5070.933,1035.51;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;205;4660.082,1194.042;Inherit;False;Property;_LightingColorweight;Lighting Color weight;4;0;Create;True;0;0;0;False;0;False;0.7860179;0.7860179;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;139;3593.026,-27.90154;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;332;5736.522,1240.435;Inherit;False;Property;_ShadowAmbient;ShadowAmbient;9;0;Create;True;0;0;0;False;0;False;0.2782227;0.091;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;204;5282.111,1343.945;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;344;5722.398,1346.457;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;356;6111.314,1168.273;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;382;6821.149,1050.696;Inherit;False;Property;_Debug;Debug;19;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;326;-493.5218,447.26;Inherit;False;Tangent;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;216;-323.4828,-1709.143;Inherit;True;NDotCL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;222;-968.214,-1699.133;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RGBToHSVNode;328;-179.3705,364.0617;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;226;-1351.411,-1811.422;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;386;6287.666,812.03;Inherit;False;Debug;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;383;6857.002,1517.895;Inherit;False;Property;_Debug;Debug;19;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;382;True;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;212;-562.7325,-1704.27;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;323;-411.0189,872.1194;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;329;70.57281,381.4707;Inherit;False;Ambient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;215;-786.886,-1697.332;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;353;6510.229,1065.017;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;211;-1364.808,-1698.887;Inherit;False;Property;_Custom_GlobalLight;Custom_GlobalLight;13;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;214;-832.0682,-1566.229;Inherit;False;183;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;4632.08,1357.199;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;385;6591.264,1623.622;Inherit;False;386;Debug;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;7210.745,1203.381;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;CosmicHell/R&D/CH_Enviro_V1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;2.3;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;314;5;315;0
WireConnection;133;0;314;0
WireConnection;183;0;133;0
WireConnection;132;0;131;0
WireConnection;132;1;184;0
WireConnection;206;0;132;0
WireConnection;275;0;274;0
WireConnection;275;1;273;0
WireConnection;143;0;207;0
WireConnection;148;0;147;0
WireConnection;148;1;129;0
WireConnection;276;0;275;0
WireConnection;348;0;198;0
WireConnection;152;0;148;1
WireConnection;152;1;153;0
WireConnection;278;0;276;0
WireConnection;200;0;143;0
WireConnection;200;1;348;0
WireConnection;300;0;200;0
WireConnection;300;1;152;0
WireConnection;282;0;281;0
WireConnection;282;1;279;0
WireConnection;337;0;300;0
WireConnection;186;0;188;0
WireConnection;186;1;187;0
WireConnection;283;0;282;0
WireConnection;126;0;127;0
WireConnection;126;1;129;0
WireConnection;155;0;126;0
WireConnection;208;0;186;0
WireConnection;284;0;283;0
WireConnection;284;1;292;0
WireConnection;306;0;303;0
WireConnection;264;0;126;0
WireConnection;179;0;200;0
WireConnection;179;4;180;0
WireConnection;134;0;300;0
WireConnection;307;0;306;0
WireConnection;158;0;155;1
WireConnection;158;1;161;0
WireConnection;160;0;155;3
WireConnection;160;1;164;0
WireConnection;159;0;155;2
WireConnection;159;1;163;0
WireConnection;286;0;284;0
WireConnection;191;0;209;0
WireConnection;178;0;179;0
WireConnection;178;1;148;2
WireConnection;268;0;264;1
WireConnection;268;1;262;0
WireConnection;166;0;158;0
WireConnection;144;0;134;0
WireConnection;266;0;264;2
WireConnection;266;1;263;0
WireConnection;305;0;286;0
WireConnection;305;1;307;0
WireConnection;267;0;264;3
WireConnection;267;1;265;0
WireConnection;168;0;160;0
WireConnection;167;0;159;0
WireConnection;270;0;267;0
WireConnection;285;0;305;0
WireConnection;189;0;191;0
WireConnection;189;1;190;0
WireConnection;171;0;178;0
WireConnection;171;1;172;0
WireConnection;156;0;166;0
WireConnection;156;1;167;0
WireConnection;156;2;168;0
WireConnection;169;0;207;0
WireConnection;271;0;268;0
WireConnection;269;0;266;0
WireConnection;135;0;144;0
WireConnection;201;0;169;0
WireConnection;201;1;348;0
WireConnection;272;0;271;0
WireConnection;272;1;269;0
WireConnection;272;2;270;0
WireConnection;287;0;285;0
WireConnection;192;0;189;0
WireConnection;177;0;171;0
WireConnection;157;0;156;0
WireConnection;157;1;126;0
WireConnection;157;2;135;0
WireConnection;333;0;201;0
WireConnection;288;0;157;0
WireConnection;288;1;272;0
WireConnection;288;2;287;0
WireConnection;194;0;192;0
WireConnection;194;1;177;0
WireConnection;403;0;404;0
WireConnection;403;1;288;0
WireConnection;403;2;194;0
WireConnection;138;0;333;0
WireConnection;138;1;170;0
WireConnection;145;0;138;0
WireConnection;202;0;199;0
WireConnection;202;1;403;0
WireConnection;139;0;145;0
WireConnection;204;0;202;0
WireConnection;204;1;403;0
WireConnection;204;2;205;0
WireConnection;344;0;204;0
WireConnection;344;1;139;0
WireConnection;356;0;403;0
WireConnection;356;1;332;0
WireConnection;382;1;356;0
WireConnection;326;0;314;0
WireConnection;216;0;212;0
WireConnection;222;0;226;0
WireConnection;222;1;211;0
WireConnection;328;0;326;0
WireConnection;383;1;344;0
WireConnection;212;0;215;0
WireConnection;212;1;214;0
WireConnection;323;0;314;0
WireConnection;329;0;328;3
WireConnection;215;0;222;0
WireConnection;353;0;356;0
WireConnection;142;1;288;0
WireConnection;0;2;382;0
WireConnection;0;13;383;0
ASEEND*/
//CHKSM=C0DD48D14AA43A18A0CF46C56721B9E7417DC18D