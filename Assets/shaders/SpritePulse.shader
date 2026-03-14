Shader "Custom/SpritePulse"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _PulseColor ("Pulse Color", Color) = (1, 1, 1, 1)
        _PulseSpeed ("Pulse Speed", Range(0.1, 10)) = 3
        _PulseMin ("Min Brightness", Range(0.2, 1)) = 0.6
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
        Lighting Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _PulseColor;
            float _PulseSpeed;
            float _PulseMin;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * i.color;
                float wave = (sin(_Time.y * _PulseSpeed) + 1.0) * 0.5;
                float pulse = lerp(_PulseMin, 1.0, wave);

                col.rgb *= _PulseColor.rgb * pulse;
                col.a *= _PulseColor.a;
                return col;
            }
            ENDCG
        }
    }
}
