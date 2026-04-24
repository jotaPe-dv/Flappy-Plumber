Shader "Custom/HitFlash"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _HitColor ("Hit Color", Color) = (1, 0, 0, 1)
        _HitTime ("Hit Time", Float) = -999
        _FlashDuration ("Flash Duration", Float) = 0.5
        _FlashSpeed ("Flash Speed", Float) = 10.0
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "Queue"="Opaque"
            "RenderType"="Opaque"
        }

        Pass
        {
            Name "UniversalForward"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv          : TEXCOORD0;
                float3 positionWS  : TEXCOORD1;
                float3 normalWS    : TEXCOORD2;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                half4  _BaseColor;
                half4  _HitColor;
                float  _HitTime;
                float  _FlashDuration;
                float  _FlashSpeed;
            CBUFFER_END

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                output.positionWS  = TransformObjectToWorld(input.positionOS.xyz);
                output.normalWS    = TransformObjectToWorldNormal(input.normalOS);
                output.uv          = TRANSFORM_TEX(input.uv, _BaseMap);
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                half4 texColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);

                // Tiempo transcurrido desde el golpe
                float elapsed = _Time.y - _HitTime;

                // Solo parpadea dentro de la ventana de FlashDuration
                float isHit = step(0.0, elapsed) * step(elapsed, _FlashDuration);

                // Oscila entre 0 y 1 rapidamente
                float flash = abs(sin(elapsed * _FlashSpeed)) * isHit;

                // Mezcla color base con color de golpe
                half4 finalColor = texColor * _BaseColor;
                finalColor.rgb = lerp(finalColor.rgb, _HitColor.rgb, flash);

                return finalColor;
            }
            ENDHLSL
        }
    }
}
