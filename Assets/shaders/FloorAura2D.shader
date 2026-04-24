Shader "Custom/FloorAura2D"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _AuraColor ("Aura Color", Color) = (0.3, 0.9, 1.0, 0.9)
        _AuraStrength ("Aura Strength", Range(0, 8)) = 2.5
        _AuraSize ("Aura Size (Texels)", Range(0, 16)) = 5.0
        _TopNeonThickness ("Top Neon Thickness", Range(0.01, 0.5)) = 0.14
        _TopNeonIntensity ("Top Neon Intensity", Range(0, 8)) = 4.0
        _TopNeonSoftness ("Top Neon Softness", Range(0.001, 0.2)) = 0.03
        _BaseBrightness ("Base Brightness", Range(0.5, 2)) = 1.0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "RenderType"="Transparent"
            "IgnoreProjector"="True"
            "CanUseSpriteAtlas"="True"
        }

        Cull Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct Attributes
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            struct Varyings
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            fixed4 _AuraColor;
            float _AuraStrength;
            float _AuraSize;
            float _TopNeonThickness;
            float _TopNeonIntensity;
            float _TopNeonSoftness;
            float _BaseBrightness;

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.vertex = UnityObjectToClipPos(input.vertex);
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                output.color = input.color;
                return output;
            }

            fixed SampleAlpha(float2 uv)
            {
                return tex2D(_MainTex, uv).a;
            }

            fixed4 frag(Varyings input) : SV_Target
            {
                fixed4 baseCol = tex2D(_MainTex, input.uv) * input.color;

                float2 texel = _MainTex_TexelSize.xy * _AuraSize;

                fixed a0 = SampleAlpha(input.uv + float2( texel.x, 0));
                fixed a1 = SampleAlpha(input.uv + float2(-texel.x, 0));
                fixed a2 = SampleAlpha(input.uv + float2(0,  texel.y));
                fixed a3 = SampleAlpha(input.uv + float2(0, -texel.y));
                fixed a4 = SampleAlpha(input.uv + texel);
                fixed a5 = SampleAlpha(input.uv - texel);
                fixed a6 = SampleAlpha(input.uv + float2( texel.x, -texel.y));
                fixed a7 = SampleAlpha(input.uv + float2(-texel.x,  texel.y));

                fixed neighborAlpha = max(max(a0, a1), max(a2, a3));
                neighborAlpha = max(neighborAlpha, max(max(a4, a5), max(a6, a7)));

                fixed glowMask = saturate(neighborAlpha - baseCol.a);
                fixed glowIntensity = glowMask * _AuraStrength;

                float topStart = 1.0 - _TopNeonThickness;
                float topBand = smoothstep(topStart - _TopNeonSoftness, topStart + _TopNeonSoftness, input.uv.y);
                float neonTop = topBand * baseCol.a * _TopNeonIntensity;

                fixed3 finalRgb = baseCol.rgb * _BaseBrightness + (_AuraColor.rgb * (glowIntensity + neonTop));
                fixed finalA = saturate(baseCol.a + glowMask * _AuraColor.a * _AuraStrength * 0.5 + neonTop * 0.2);

                return half4(finalRgb, finalA);
            }
            ENDCG
        }
    }
}
