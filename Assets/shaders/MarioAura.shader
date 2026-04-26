Shader "Custom/MarioAura"
{
    Properties
    {
        _AuraColor ("Aura Color", Color) = (0.5, 0.8, 1, 0.6)
        _AuraSize ("Aura Size", Range(0.1, 2.0)) = 0.3
        _PulseSpeed ("Pulse Speed", Range(0.5, 5.0)) = 2.0
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }

        Pass
        {
            Name "Aura"
            Cull Back
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float  fresnel     : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
                half4  _AuraColor;
                float  _AuraSize;
                float  _PulseSpeed;
            CBUFFER_END

            Varyings vert(Attributes input)
            {
                Varyings output;

                // Expande la esfera segun AuraSize
                float3 expanded = input.positionOS.xyz * (1.0 + _AuraSize);
                output.positionHCS = TransformObjectToHClip(expanded);

                // Fresnel: mas brillante en los bordes
                float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
                float3 viewDir = normalize(GetWorldSpaceViewDir(TransformObjectToWorld(input.positionOS.xyz)));
                output.fresnel = 1.0 - saturate(dot(normalWS, viewDir));

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                // Pulso suave constante
                float pulse = (sin(_Time.y * _PulseSpeed) + 1.0) * 0.5;
                float alpha = input.fresnel * _AuraColor.a * (0.6 + 0.4 * pulse);
                return half4(_AuraColor.rgb, alpha);
            }
            ENDHLSL
        }
    }
}
