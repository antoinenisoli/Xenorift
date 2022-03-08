// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "CosmicHell/R&D/CH_Characters_V1"
{
	Properties
	{
		[SingleLineTexture][Header(Main Maps)][Space(15)]_Albedo("Albedo", 2D) = "white" {}
		[SingleLineTexture]_NormalMap("Normal Map", 2D) = "bump" {}
		[SingleLineTexture]_ThresholdMapRCellGShadow("Threshold Map (R = Cell G = Shadow)", 2D) = "white" {}
		[NoScaleOffset][SingleLineTexture]_Emissive("Emissive", 2D) = "white" {}
		_EmissiveIntensity("Emissive Intensity", Float) = 0
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
		[Header(Fresnel)][Space(15)]_FresnelR("Fresnel R", Color) = (0.2320192,1,0,0)
		_FresnelL("Fresnel L", Color) = (0.9078603,0,1,0)
		_FresnelAmountMIN("Fresnel Amount MIN", Range( 0 , 1)) = 0.6472826
		[Header(HSV Spec)][Space(15)]_HueSpec("Hue", Range( -1 , 1)) = -1
		_SaturationSpec("Saturation", Range( -1 , 1)) = 0
		_ValueSpec("Value", Range( -1 , 1)) = 0.6475888
		_SpecPow("SpecPow", Range( 1 , 100)) = 9.676549
		_NormalScale("Normal Scale", Float) = 1
		[Toggle(_DEBUG_ON)] _Debug("Debug", Float) = 0
		_Float0("Float 0", Float) = 90
		[Header(Highlight)][Space(10)]_HighlightAnimation("Highlight Animation", Range( 0 , 1)) = 0
		_IntensityFresnel("Intensity Fresnel", Range( 0 , 1)) = 0
		[HDR]_HighlightColor("Highlight Color", Color) = (1.04509,7.171482,8.324685,1)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
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

		uniform sampler2D _Emissive;
		uniform float _EmissiveIntensity;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _NormalScale;
		uniform float _FresnelShadow;
		uniform float _AO_LightInput;
		uniform sampler2D _ThresholdMapRCellGShadow;
		uniform float _AO_Threshold;
		uniform sampler2D _Albedo;
		uniform float _Hue;
		uniform float _Saturation;
		uniform float _Value;
		uniform float _CellThreshold;
		uniform float _HueSpec;
		uniform float _SaturationSpec;
		uniform float _ValueSpec;
		uniform float _SpecPow;
		uniform float _ShadowAmbient;
		uniform float4 _FresnelR;
		uniform float4 _FresnelL;
		uniform float _Float0;
		uniform float _FresnelAmountMIN;
		uniform float _HighlightAnimation;
		uniform float _LightingColorweight;
		uniform float _Shadow_Threshold;
		uniform float4 _HighlightColor;
		uniform float _IntensityFresnel;


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

		float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
		{
			original -= center;
			float C = cos( angle );
			float S = sin( angle );
			float t = 1 - C;
			float m00 = t * u.x * u.x + C;
			float m01 = t * u.x * u.y - S * u.z;
			float m02 = t * u.x * u.z + S * u.y;
			float m10 = t * u.x * u.y + S * u.z;
			float m11 = t * u.y * u.y + C;
			float m12 = t * u.y * u.z - S * u.x;
			float m20 = t * u.x * u.z - S * u.y;
			float m21 = t * u.y * u.z + S * u.x;
			float m22 = t * u.z * u.z + C;
			float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
			return mul( finalMatrix, original ) + center;
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
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 tex2DNode314 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalScale );
			float3 WorldNormal183 = (WorldNormalVector( i , tex2DNode314 ));
			float dotResult186 = dot( ase_worldViewDir , WorldNormal183 );
			float NdotV208 = dotResult186;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult132 = dot( ase_worldlightDir , WorldNormal183 );
			float NDotL206 = dotResult132;
			float temp_output_348_0 = saturate( ase_lightAtten );
			float temp_output_200_0 = ( saturate( NDotL206 ) * temp_output_348_0 );
			float4 tex2DNode148 = tex2D( _ThresholdMapRCellGShadow, i.uv_texcoord );
			float4 tex2DNode126 = tex2D( _Albedo, i.uv_texcoord );
			float3 hsvTorgb155 = RGBToHSV( tex2DNode126.rgb );
			float3 hsvTorgb156 = HSVToRGB( float3(saturate( ( hsvTorgb155.x + _Hue ) ),saturate( ( hsvTorgb155.y + _Saturation ) ),saturate( ( hsvTorgb155.z + _Value ) )) );
			float temp_output_300_0 = ( temp_output_200_0 - pow( tex2DNode148.r , _CellThreshold ) );
			float4 lerpResult157 = lerp( float4( hsvTorgb156 , 0.0 ) , tex2DNode126 , ( 1.0 - saturate( step( temp_output_300_0 , 0.0 ) ) ));
			float3 hsvTorgb264 = RGBToHSV( tex2DNode126.rgb );
			float3 hsvTorgb272 = HSVToRGB( float3(saturate( ( hsvTorgb264.x + _HueSpec ) ),saturate( ( hsvTorgb264.y + _SaturationSpec ) ),saturate( ( hsvTorgb264.z + _ValueSpec ) )) );
			float3 normalizeResult276 = normalize( ( ase_worldlightDir + ase_worldViewDir ) );
			float3 HalfView278 = normalizeResult276;
			float dotResult282 = dot( WorldNormal183 , HalfView278 );
			float CellNoFilter337 = temp_output_300_0;
			float4 lerpResult288 = lerp( lerpResult157 , float4( hsvTorgb272 , 0.0 ) , ( 1.0 - step( ( saturate( pow( saturate( dotResult282 ) , _SpecPow ) ) - ( 1.0 - saturate( CellNoFilter337 ) ) ) , 0.5 ) ));
			float4 temp_output_142_0 = ( ( ( 1.0 - step( saturate( NdotV208 ) , _FresnelShadow ) ) * ( 1.0 - step( ( (0.0 + (temp_output_200_0 - 0.0) * (_AO_LightInput - 0.0) / (1.0 - 0.0)) + tex2DNode148.g ) , _AO_Threshold ) ) ) * lerpResult288 );
			float4 lerpResult204 = lerp( ( ase_lightColor * temp_output_142_0 ) , temp_output_142_0 , _LightingColorweight);
			float4 CelShading452 = ( lerpResult204 * ( 1.0 - saturate( step( saturate( ( (0.0 + (NDotL206 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) * temp_output_348_0 ) ) , _Shadow_Threshold ) ) ) );
			float4 tex2DNode403 = tex2D( _Emissive, i.uv_texcoord );
			float4 Emissive448 = tex2DNode403;
			float fresnelNdotV422 = dot( (WorldNormalVector( i , WorldNormal183 )), ase_worldViewDir );
			float fresnelNode422 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV422, 2.0 ) );
			float4 lerpResult444 = lerp( CelShading452 , ( ( _HighlightColor * 0.02 ) + ( _HighlightColor * ( Emissive448.r + saturate( floor( ( fresnelNode422 * 0.5 ) ) ) ) ) ) , _HighlightAnimation);
			float mulTime434 = _Time.y * 4.0;
			float4 _HighlightRemap = float4(0,1,-1,1.25);
			float4 CustomLighting446 = ( lerpResult444 * ( (_HighlightRemap.z + (frac( ( _HighlightAnimation * mulTime434 ) ) - _HighlightRemap.x) * (_HighlightRemap.w - _HighlightRemap.z) / (_HighlightRemap.y - _HighlightRemap.x)) * _IntensityFresnel ) );
			#ifdef _DEBUG_ON
				float4 staticSwitch383 = float4( 0,0,0,0 );
			#else
				float4 staticSwitch383 = CustomLighting446;
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
			float4 tex2DNode403 = tex2D( _Emissive, i.uv_texcoord );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 tex2DNode314 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalScale );
			float3 WorldNormal183 = (WorldNormalVector( i , tex2DNode314 ));
			float dotResult186 = dot( ase_worldViewDir , WorldNormal183 );
			float NdotV208 = dotResult186;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult132 = dot( ase_worldlightDir , WorldNormal183 );
			float NDotL206 = dotResult132;
			float temp_output_348_0 = saturate( 1 );
			float temp_output_200_0 = ( saturate( NDotL206 ) * temp_output_348_0 );
			float4 tex2DNode148 = tex2D( _ThresholdMapRCellGShadow, i.uv_texcoord );
			float4 tex2DNode126 = tex2D( _Albedo, i.uv_texcoord );
			float3 hsvTorgb155 = RGBToHSV( tex2DNode126.rgb );
			float3 hsvTorgb156 = HSVToRGB( float3(saturate( ( hsvTorgb155.x + _Hue ) ),saturate( ( hsvTorgb155.y + _Saturation ) ),saturate( ( hsvTorgb155.z + _Value ) )) );
			float temp_output_300_0 = ( temp_output_200_0 - pow( tex2DNode148.r , _CellThreshold ) );
			float4 lerpResult157 = lerp( float4( hsvTorgb156 , 0.0 ) , tex2DNode126 , ( 1.0 - saturate( step( temp_output_300_0 , 0.0 ) ) ));
			float3 hsvTorgb264 = RGBToHSV( tex2DNode126.rgb );
			float3 hsvTorgb272 = HSVToRGB( float3(saturate( ( hsvTorgb264.x + _HueSpec ) ),saturate( ( hsvTorgb264.y + _SaturationSpec ) ),saturate( ( hsvTorgb264.z + _ValueSpec ) )) );
			float3 normalizeResult276 = normalize( ( ase_worldlightDir + ase_worldViewDir ) );
			float3 HalfView278 = normalizeResult276;
			float dotResult282 = dot( WorldNormal183 , HalfView278 );
			float CellNoFilter337 = temp_output_300_0;
			float4 lerpResult288 = lerp( lerpResult157 , float4( hsvTorgb272 , 0.0 ) , ( 1.0 - step( ( saturate( pow( saturate( dotResult282 ) , _SpecPow ) ) - ( 1.0 - saturate( CellNoFilter337 ) ) ) , 0.5 ) ));
			float4 temp_output_142_0 = ( ( ( 1.0 - step( saturate( NdotV208 ) , _FresnelShadow ) ) * ( 1.0 - step( ( (0.0 + (temp_output_200_0 - 0.0) * (_AO_LightInput - 0.0) / (1.0 - 0.0)) + tex2DNode148.g ) , _AO_Threshold ) ) ) * lerpResult288 );
			float3 rotatedValue390 = RotateAroundAxis( UNITY_MATRIX_V[0].xyz, float3( 0,0,0 ), ase_worldViewDir, _Float0 );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float dotResult379 = dot( rotatedValue390 , ase_worldNormal );
			float4 lerpResult248 = lerp( _FresnelR , _FresnelL , step( (0.0 + (dotResult379 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) , 0.5 ));
			float dotResult233 = dot( rotatedValue390 , ase_worldNormal );
			float dotResult240 = dot( ( rotatedValue390 * float3(-1,0,0) ) , ase_worldNormal );
			float temp_output_260_0 = ( ( ( 1.0 - step( (0.0 + (dotResult233 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) , 0.0 ) ) + ( 1.0 - step( (0.0 + (dotResult240 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) , 0.0 ) ) ) * step( saturate( NdotV208 ) , _FresnelAmountMIN ) );
			float4 temp_output_350_0 = ( lerpResult248 * saturate( temp_output_260_0 ) );
			float4 lerpResult353 = lerp( ( temp_output_142_0 * _ShadowAmbient ) , temp_output_350_0 , temp_output_260_0);
			float Highlight456 = _HighlightAnimation;
			float4 lerpResult454 = lerp( ( tex2DNode403 * _EmissiveIntensity ) , lerpResult353 , Highlight456);
			#ifdef _DEBUG_ON
				float4 staticSwitch382 = temp_output_350_0;
			#else
				float4 staticSwitch382 = saturate( ( lerpResult454 + lerpResult353 ) );
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
1927;0;1913;1019;-5390.724;-1539.079;1.545;True;False
Node;AmplifyShaderEditor.RangedFloatNode;315;-1096.106,609.9106;Inherit;False;Property;_NormalScale;Normal Scale;28;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;314;-787.5122,559.9495;Inherit;True;Property;_NormalMap;Normal Map;1;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;71f8c3c168959e3489c6fd33f3402f1e;d0b910120776f8341b02913cf602550f;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;133;-369.4031,561.7445;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;183;-65.81166,558.355;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;131;-809.4396,125.797;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;184;-783.3925,272.9905;Inherit;False;183;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;132;-442.0569,179.9494;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;273;-1221.077,4161.799;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;274;-1263.419,4023.561;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;206;-36.02954,164.1188;Inherit;False;NDotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;275;-960.8811,4059.163;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;147;1498.95,878.3152;Inherit;True;Property;_ThresholdMapRCellGShadow;Threshold Map (R = Cell G = Shadow);2;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;27c4d73d01a535645b616213aa842a5a;42884e6d45488a4409402d88fd0876b7;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;207;927.1783,185.68;Inherit;False;206;NDotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;198;1688.075,492.5429;Inherit;True;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;129;1526.765,1679.873;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;143;1664.495,186.8112;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;276;-758.4187,4061.561;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;348;1952.304,495.3904;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;148;1853.736,876.3846;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;153;2325.423,854.8844;Inherit;False;Property;_CellThreshold;Cell Threshold;5;1;[IntRange];Create;True;0;0;0;False;0;False;1.348499;2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;152;2600.092,903.5641;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;278;-542.2968,4060.285;Inherit;False;HalfView;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;200;2377.428,494.7634;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;281;410.955,3971.894;Inherit;False;183;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;279;431.8975,4052.302;Inherit;False;278;HalfView;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;300;2745.843,512.0724;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;127;1417.88,1434.835;Inherit;True;Property;_Albedo;Albedo;0;1;[SingleLineTexture];Create;True;0;0;0;False;2;Header(Main Maps);Space(15);False;af520b8dea87bd24dbfd9c7e36b41b11;af520b8dea87bd24dbfd9c7e36b41b11;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;187;-633.3996,-110.3681;Inherit;False;183;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;400;840.5983,-2941.621;Inherit;False;774.0595;480.4426;MAGIC rotate view dir by UpVector Camera;5;396;398;392;389;390;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;337;3070.504,764.7732;Inherit;False;CellNoFilter;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;282;714.1743,3996.237;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;188;-625.6299,-277.4166;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;283;941.2842,3998.274;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;186;-365.0219,-246.1448;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;292;820.1805,4228.113;Inherit;False;Property;_SpecPow;SpecPow;27;0;Create;True;0;0;0;False;0;False;9.676549;5.4;1;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;303;1244.155,4339.526;Inherit;True;337;CellNoFilter;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;126;2029.865,1438.073;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewMatrixNode;396;890.5983,-2667.697;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.RangedFloatNode;392;1048.849,-2748.706;Inherit;False;Property;_Float0;Float 0;30;0;Create;True;0;0;0;False;0;False;90;90;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;389;1023.772,-2891.621;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;306;1453.064,4318.421;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;161;2634.327,1835.517;Inherit;False;Property;_Hue;Hue;7;0;Create;True;0;0;0;False;2;Header(HSV Shadow);Space(15);False;0;-0.074;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;163;2644.896,1922.529;Inherit;False;Property;_Saturation;Saturation;8;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;164;2645.384,2000.611;Inherit;False;Property;_Value;Value;9;0;Create;True;0;0;0;False;0;False;0;-0.346;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;180;2188.828,-586.137;Inherit;False;Property;_AO_LightInput;AO_LightInput;13;0;Create;True;0;0;0;False;0;False;1;0.349;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;398;1027.616,-2668.178;Inherit;False;Row;0;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RGBToHSVNode;155;2422.122,2003.032;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;284;1125.174,3992.237;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;12.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;208;-64.69812,-201.2535;Inherit;False;NdotV;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;263;2614.182,2632.354;Inherit;False;Property;_SaturationSpec;Saturation;25;0;Create;False;0;0;0;False;0;False;0;-0.118;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;265;2614.67,2711.935;Inherit;False;Property;_ValueSpec;Value;26;0;Create;False;0;0;0;False;0;False;0.6475888;0.457;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;307;1624.978,4313.149;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;134;3061.821,524.9175;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;264;2391.408,2712.857;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RotateAboutAxisNode;390;1294.658,-2779.801;Inherit;False;False;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;286;1447.022,3985.687;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;179;2508.179,-664.5571;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;159;3059.318,2132.761;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;160;3061,2238.834;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;158;3052.855,2031.102;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;262;2603.613,2545.342;Inherit;False;Property;_HueSpec;Hue;24;0;Create;False;0;0;0;False;2;Header(HSV Spec);Space(15);False;-1;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;209;2548.936,-1087.502;Inherit;True;208;NdotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;166;3191.201,2029.297;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;268;3022.141,2740.927;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;181;2372.122,1785.517;Inherit;False;1482.393;588.3171;Shadow Color;1;156;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;399;1952,-2352;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;178;2980.974,-636.4559;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;167;3194.24,2125.729;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;168;3198.24,2257.729;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;144;3294.209,531.3458;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;267;3030.286,2948.659;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;266;3028.604,2842.586;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;190;2836.695,-946.8514;Inherit;False;Property;_FresnelShadow;Fresnel Shadow;14;0;Create;True;0;0;0;False;0;False;0.2085736;0.56;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;172;2231.628,-672.7682;Inherit;False;Property;_AO_Threshold;AO_Threshold;12;0;Create;True;0;0;0;False;0;False;0.6661413;0.718;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;294;1381.5,-2025.882;Inherit;False;Constant;_Vector0;Vector 0;16;0;Create;True;0;0;0;False;0;False;-1,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;415;5847.423,1768.411;Inherit;False;3191.744;1820.83;;26;446;445;444;442;447;440;432;438;433;463;429;425;450;428;459;451;449;460;422;461;419;417;420;418;416;458;Highlight Effect;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;191;2916.423,-1081.836;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;305;1875.99,4026.423;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;271;3160.487,2739.122;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;171;3259.321,-673.776;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;236;2365.785,-2083.234;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StepOpNode;189;3168.324,-1098.313;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;293;1618.362,-2076.958;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.HSVToRGBNode;156;3616.515,2039.323;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;414;5904.685,104.4758;Inherit;False;1627.791;660.213;Comment;10;411;454;410;412;413;448;403;404;408;457;Emissive;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;270;3167.526,2967.554;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;242;2357.273,-1741.551;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;458;5932.786,2171.97;Inherit;False;183;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;169;2116.694,-225.8525;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;269;3163.526,2835.554;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;135;3566.09,525.5297;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;285;2212.961,3983.488;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;419;6185.902,2369.922;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;201;2424.516,-112.0611;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;408;5966.57,174.5158;Inherit;True;Property;_Emissive;Emissive;3;2;[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;None;dbc7709107e52834ab67cee1b3cd0c77;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;416;6232.747,2660.586;Inherit;False;Constant;_HighlightScale;HighlightScale;11;0;Create;True;0;0;0;False;0;False;1;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;418;6232.746,2748.215;Inherit;False;Constant;_HighlightPower;HighlightPower;36;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;417;6161.061,2177.72;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;177;3498.943,-628.8842;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;404;5969.054,401.6898;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;287;2530.756,3985.455;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;233;2618.127,-2144.44;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;272;3585.801,2749.148;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;192;3534.622,-1094.528;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;240;2569.434,-1821.491;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;157;3852.76,1390.079;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;420;6235.75,2564.809;Inherit;False;Constant;_HighlightBias;HighlightBias;8;0;Create;True;0;0;0;False;0;False;0;-1.23;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;422;6491.735,2487.017;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;194;4330.289,-861.1122;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;333;2816.689,-224.7851;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;244;2862.818,-1801.205;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;403;6264.698,282.2617;Inherit;True;Property;_txtBody_Emissive;txtBody_Emissive;29;0;Create;True;0;0;0;False;0;False;-1;dbc7709107e52834ab67cee1b3cd0c77;dbc7709107e52834ab67cee1b3cd0c77;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;237;2877.268,-2136.987;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;461;6823.749,2629.511;Inherit;False;Constant;_FresnelAmount;Fresnel Amount;34;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;170;2743.943,101.1334;Inherit;False;Property;_Shadow_Threshold;Shadow_Threshold;10;0;Create;True;0;0;0;False;2;Header(Shadow);Space(15);False;0.5;0.894;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;288;4235.193,1384.444;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;238;3233.743,-1732.856;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;138;3060.406,11.74025;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;4615.566,1357.199;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;460;7099.095,2557.545;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;199;4612.084,974.9456;Inherit;True;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.StepOpNode;231;3168.143,-2109.379;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;448;6626.643,237.0246;Inherit;False;Emissive;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;255;3123.103,-2740.847;Inherit;False;208;NdotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;451;7243.322,2874.673;Inherit;False;1536.802;611.176;Comment;10;466;465;456;443;439;441;436;435;434;427;Animated Highlight;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;378;2376.741,-2390.536;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;202;5070.933,1035.51;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FloorOpNode;459;7239.146,2556.966;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;449;6216.107,2041.107;Inherit;False;448;Emissive;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;232;3542.324,-2123.508;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;379;2747.358,-2416.837;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;205;4660.082,1194.042;Inherit;False;Property;_LightingColorweight;Lighting Color weight;6;0;Create;True;0;0;0;False;0;False;0.7860179;0.39;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;257;3490.59,-2735.181;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;401;3542.513,-1732.696;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;145;3297.72,-25.17644;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;427;7293.322,3059.024;Inherit;False;Constant;_SpeedHightlight;Speed Hightlight;35;0;Create;True;0;0;0;False;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;230;2735.056,-3002.01;Inherit;False;Property;_FresnelAmountMIN;Fresnel Amount MIN;21;0;Create;True;0;0;0;False;0;False;0.6472826;0.508;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;204;5239.111,1343.945;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;249;4007.667,-1791.687;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;450;6440.703,2045.246;Inherit;True;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TFHCRemapNode;380;3081.479,-2420.049;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;428;6693.729,1921.945;Inherit;False;Property;_HighlightColor;Highlight Color;33;1;[HDR];Create;True;0;0;0;False;0;False;1.04509,7.171482,8.324685,1;0,6.4,11.98431,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;435;7462.596,2932.083;Inherit;False;Property;_HighlightAnimation;Highlight Animation;31;0;Create;True;0;0;0;False;2;Header(Highlight);Space(10);False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;434;7552.123,3067.249;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;425;7359.427,2558.007;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;139;3593.026,-27.90154;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;258;3817.09,-2735.958;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;344;5739.398,1359.457;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;246;3772.003,-1523.712;Inherit;False;Property;_FresnelL;Fresnel L;16;0;Create;True;0;0;0;False;0;False;0.9078603,0,1,0;1,0,0.2554805,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;381;3353.179,-2412.184;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;429;6919.335,2095.764;Inherit;False;Constant;_HighlightIntensity;Highlight Intensity;33;0;Create;True;0;0;0;False;0;False;0.02;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;245;3772.742,-2405.466;Inherit;False;Property;_FresnelR;Fresnel R;15;0;Create;True;0;0;0;False;2;Header(Fresnel);Space(15);False;0.2320192,1,0,0;0.06203479,1,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;433;7367.233,2381.927;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;436;7829.123,2979.248;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;260;4414.418,-2184.811;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;463;7555.184,2481.322;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;439;8050.123,3117.249;Inherit;False;Constant;_HighlightRemap;Highlight Remap;2;0;Create;True;0;0;0;False;0;False;0,1,-1,1.25;0,1,-1,1.25;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;441;8031.123,2979.248;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;402;4478.674,-2009.362;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;432;7195.455,2030.419;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;332;5736.522,1240.435;Inherit;False;Property;_ShadowAmbient;ShadowAmbient;11;0;Create;True;0;0;0;False;0;False;0.2782227;0.372;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;452;5993.708,1356.988;Inherit;False;CelShading;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;438;7711.507,2410.447;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;248;3999.952,-2049.142;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;356;6111.314,1168.273;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;443;8295.124,3123.249;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;456;7824.412,3167.741;Inherit;False;Highlight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;350;6052.587,826.3406;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;440;8080.852,2816.148;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;442;8023.015,2362.788;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;465;8202.399,3348.182;Inherit;False;Property;_IntensityFresnel;Intensity Fresnel;32;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;413;6282.343,540.4042;Inherit;False;Property;_EmissiveIntensity;Emissive Intensity;4;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;447;7957.37,2123.583;Inherit;True;452;CelShading;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;457;6682.675,581.8148;Inherit;False;456;Highlight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;353;6546.094,1093.28;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;466;8589.803,3207.782;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;412;6686.038,428.6289;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;444;8303.6,2338.387;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;454;6982.668,528.8439;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;445;8589.207,2335.522;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;410;7218.839,642.2534;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;446;8788.744,2327.901;Inherit;False;CustomLighting;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;411;7360.239,639.1633;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;453;6870.456,1534.025;Inherit;False;446;CustomLighting;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RGBToHSVNode;328;-179.3705,364.0617;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StaticSwitch;382;7690.237,933.7961;Inherit;False;Property;_Debug;Debug;29;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;226;-1351.411,-1811.422;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;323;-411.0189,872.1194;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;375;3549.197,-3002.582;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;222;-968.214,-1699.133;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;214;-832.0682,-1566.229;Inherit;False;183;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;373;2736.268,-2921.119;Inherit;False;Property;_FresnelAmountMax;Fresnel Amount Max;19;0;Create;True;0;0;0;False;0;False;0.6472826;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;235;1385.993,-2185.16;Inherit;False;Property;_Fresnel_Side;Fresnel_Side;23;0;Create;True;0;0;0;False;0;False;1,0,0;1,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;256;3410.862,-2600.197;Inherit;False;Property;_FresnelSideMask;Fresnel Side Mask;17;0;Create;True;0;0;0;False;0;False;1;0.517;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;329;70.57281,381.4707;Inherit;False;Ambient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;326;-493.5218,447.26;Inherit;False;Tangent;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;212;-562.7325,-1704.27;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;216;-323.4828,-1709.143;Inherit;True;NDotCL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;215;-786.886,-1697.332;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;368;3138.379,-3259.61;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;10;False;2;FLOAT;20;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;374;3381.417,-3260.681;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;383;7149.771,1535.549;Inherit;False;Property;_Debug;Debug;29;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;382;True;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;372;2792.396,-3095.119;Inherit;False;Property;_DistancemaxFresnel;Distance max Fresnel;18;0;Create;True;0;0;0;False;0;False;20;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;369;2812.365,-3262.336;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;385;6540.786,1621.442;Inherit;False;386;Debug;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;371;2800.482,-3180.263;Inherit;False;Property;_DistanceminFresnel;Distance min Fresnel;20;0;Create;True;0;0;0;False;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;386;6640.676,-141.7842;Inherit;False;Debug;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;211;-1364.808,-1698.887;Inherit;False;Property;_Custom_GlobalLight;Custom_GlobalLight;22;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;7900.767,1040.255;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;CosmicHell/R&D/CH_Characters_V1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;2.3;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;175;2090.06,-313.924;Inherit;False;1919.919;544.87;Shadow;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;277;-1306.419,3956.799;Inherit;False;1034.451;381.4189;HalfView;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;210;2138.828,-741.4634;Inherit;False;1539.115;341.3201;AO_Shadow;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;197;2359.824,-1198.18;Inherit;False;1353.797;367.3293;FresnelShadow;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;254;2933.99,-2851.525;Inherit;False;1353.797;367.3293;FresnelShadow;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;227;2359.643,-2209.246;Inherit;False;1353.797;367.3293;FresnelSide;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;182;2342.208,450.2069;Inherit;False;1421.881;608.2914;Cell;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;261;2341.408,2495.342;Inherit;False;1482.393;588.3171;Shadow Color;0;;1,1,1,1;0;0
WireConnection;314;5;315;0
WireConnection;133;0;314;0
WireConnection;183;0;133;0
WireConnection;132;0;131;0
WireConnection;132;1;184;0
WireConnection;206;0;132;0
WireConnection;275;0;274;0
WireConnection;275;1;273;0
WireConnection;143;0;207;0
WireConnection;276;0;275;0
WireConnection;348;0;198;0
WireConnection;148;0;147;0
WireConnection;148;1;129;0
WireConnection;152;0;148;1
WireConnection;152;1;153;0
WireConnection;278;0;276;0
WireConnection;200;0;143;0
WireConnection;200;1;348;0
WireConnection;300;0;200;0
WireConnection;300;1;152;0
WireConnection;337;0;300;0
WireConnection;282;0;281;0
WireConnection;282;1;279;0
WireConnection;283;0;282;0
WireConnection;186;0;188;0
WireConnection;186;1;187;0
WireConnection;126;0;127;0
WireConnection;126;1;129;0
WireConnection;306;0;303;0
WireConnection;398;0;396;0
WireConnection;155;0;126;0
WireConnection;284;0;283;0
WireConnection;284;1;292;0
WireConnection;208;0;186;0
WireConnection;307;0;306;0
WireConnection;134;0;300;0
WireConnection;264;0;126;0
WireConnection;390;0;389;0
WireConnection;390;1;392;0
WireConnection;390;2;398;0
WireConnection;286;0;284;0
WireConnection;179;0;200;0
WireConnection;179;4;180;0
WireConnection;159;0;155;2
WireConnection;159;1;163;0
WireConnection;160;0;155;3
WireConnection;160;1;164;0
WireConnection;158;0;155;1
WireConnection;158;1;161;0
WireConnection;166;0;158;0
WireConnection;268;0;264;1
WireConnection;268;1;262;0
WireConnection;399;0;390;0
WireConnection;178;0;179;0
WireConnection;178;1;148;2
WireConnection;167;0;159;0
WireConnection;168;0;160;0
WireConnection;144;0;134;0
WireConnection;267;0;264;3
WireConnection;267;1;265;0
WireConnection;266;0;264;2
WireConnection;266;1;263;0
WireConnection;191;0;209;0
WireConnection;305;0;286;0
WireConnection;305;1;307;0
WireConnection;271;0;268;0
WireConnection;171;0;178;0
WireConnection;171;1;172;0
WireConnection;189;0;191;0
WireConnection;189;1;190;0
WireConnection;293;0;399;0
WireConnection;293;1;294;0
WireConnection;156;0;166;0
WireConnection;156;1;167;0
WireConnection;156;2;168;0
WireConnection;270;0;267;0
WireConnection;169;0;207;0
WireConnection;269;0;266;0
WireConnection;135;0;144;0
WireConnection;285;0;305;0
WireConnection;201;0;169;0
WireConnection;201;1;348;0
WireConnection;417;0;458;0
WireConnection;177;0;171;0
WireConnection;287;0;285;0
WireConnection;233;0;399;0
WireConnection;233;1;236;0
WireConnection;272;0;271;0
WireConnection;272;1;269;0
WireConnection;272;2;270;0
WireConnection;192;0;189;0
WireConnection;240;0;293;0
WireConnection;240;1;242;0
WireConnection;157;0;156;0
WireConnection;157;1;126;0
WireConnection;157;2;135;0
WireConnection;422;0;417;0
WireConnection;422;4;419;0
WireConnection;422;1;420;0
WireConnection;422;2;416;0
WireConnection;422;3;418;0
WireConnection;194;0;192;0
WireConnection;194;1;177;0
WireConnection;333;0;201;0
WireConnection;244;0;240;0
WireConnection;403;0;408;0
WireConnection;403;1;404;0
WireConnection;237;0;233;0
WireConnection;288;0;157;0
WireConnection;288;1;272;0
WireConnection;288;2;287;0
WireConnection;238;0;244;0
WireConnection;138;0;333;0
WireConnection;138;1;170;0
WireConnection;142;0;194;0
WireConnection;142;1;288;0
WireConnection;460;0;422;0
WireConnection;460;1;461;0
WireConnection;231;0;237;0
WireConnection;448;0;403;0
WireConnection;202;0;199;0
WireConnection;202;1;142;0
WireConnection;459;0;460;0
WireConnection;232;0;231;0
WireConnection;379;0;390;0
WireConnection;379;1;378;0
WireConnection;257;0;255;0
WireConnection;401;0;238;0
WireConnection;145;0;138;0
WireConnection;204;0;202;0
WireConnection;204;1;142;0
WireConnection;204;2;205;0
WireConnection;249;0;232;0
WireConnection;249;1;401;0
WireConnection;450;0;449;0
WireConnection;380;0;379;0
WireConnection;434;0;427;0
WireConnection;425;0;459;0
WireConnection;139;0;145;0
WireConnection;258;0;257;0
WireConnection;258;1;230;0
WireConnection;344;0;204;0
WireConnection;344;1;139;0
WireConnection;381;0;380;0
WireConnection;433;0;428;0
WireConnection;436;0;435;0
WireConnection;436;1;434;0
WireConnection;260;0;249;0
WireConnection;260;1;258;0
WireConnection;463;0;450;0
WireConnection;463;1;425;0
WireConnection;441;0;436;0
WireConnection;402;0;260;0
WireConnection;432;0;428;0
WireConnection;432;1;429;0
WireConnection;452;0;344;0
WireConnection;438;0;433;0
WireConnection;438;1;463;0
WireConnection;248;0;245;0
WireConnection;248;1;246;0
WireConnection;248;2;381;0
WireConnection;356;0;142;0
WireConnection;356;1;332;0
WireConnection;443;0;441;0
WireConnection;443;1;439;1
WireConnection;443;2;439;2
WireConnection;443;3;439;3
WireConnection;443;4;439;4
WireConnection;456;0;435;0
WireConnection;350;0;248;0
WireConnection;350;1;402;0
WireConnection;440;0;435;0
WireConnection;442;0;432;0
WireConnection;442;1;438;0
WireConnection;353;0;356;0
WireConnection;353;1;350;0
WireConnection;353;2;260;0
WireConnection;466;0;443;0
WireConnection;466;1;465;0
WireConnection;412;0;403;0
WireConnection;412;1;413;0
WireConnection;444;0;447;0
WireConnection;444;1;442;0
WireConnection;444;2;440;0
WireConnection;454;0;412;0
WireConnection;454;1;353;0
WireConnection;454;2;457;0
WireConnection;445;0;444;0
WireConnection;445;1;466;0
WireConnection;410;0;454;0
WireConnection;410;1;353;0
WireConnection;446;0;445;0
WireConnection;411;0;410;0
WireConnection;328;0;326;0
WireConnection;382;1;411;0
WireConnection;382;0;350;0
WireConnection;323;0;314;0
WireConnection;375;0;230;0
WireConnection;375;1;373;0
WireConnection;375;2;374;0
WireConnection;222;0;226;0
WireConnection;222;1;211;0
WireConnection;329;0;328;3
WireConnection;326;0;314;0
WireConnection;212;0;215;0
WireConnection;212;1;214;0
WireConnection;216;0;212;0
WireConnection;215;0;222;0
WireConnection;368;0;369;0
WireConnection;368;1;371;0
WireConnection;368;2;372;0
WireConnection;374;0;368;0
WireConnection;383;1;453;0
WireConnection;386;0;260;0
WireConnection;0;2;382;0
WireConnection;0;13;383;0
ASEEND*/
//CHKSM=9088877787463A37693D5FCA1A55DFEEF81EC988