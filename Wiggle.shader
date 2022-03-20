Shader "Custom/Wiggle"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed ("Wiggle Speed", Range(0.0, 1.0)) = 1.0
        _Length ("Wiggle Length", Range(0.0, 10.0)) = 1.0
    }

    SubShader
    {
        Pass
        {
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                half3 light : TEXCOORD2;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float _Speed;
            float _Length;

            float smoothrandom (float f) {
                float a = frac(sin(floor(f) * 123.45) * 48763.0);
                float b = frac(sin(floor(f + 1.0) * 123.45) * 48763.0);
                return lerp(a, b, smoothstep(0.0, 1.0, frac(f)));
            }

            float3 screen(float3 a, float3 b)
            {
                return 1.0 - (1.0 - a * 1.0 - b);
            }

            v2f vert (appdata_base v)
            {   
                v2f o;
                v.vertex.x += (smoothrandom((_Time * 200.0) * _Speed) * 0.2 - 0.1) * _Length;
                v.vertex.y += (smoothrandom((_Time * 200.0 + 10000.0) * _Speed) * 0.2 - 0.1) * _Length;
                v.vertex.z += (smoothrandom((_Time * 200.0 + 20000.0) * _Speed) * 0.2 - 0.1) * _Length;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                o.light = max(0.0, dot(worldNormal, worldLight));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb = screen(col.rgb * i.light * 0.5 + 0.5, UNITY_LIGHTMODEL_AMBIENT.rgb);
                return col;
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}
