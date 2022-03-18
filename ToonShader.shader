Shader "Custom/ToonShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Shadow1 ("Shadow 1", Color) = (0.5, 0.5, 0.6, 1.0)
        _ShadowThreshold1 ("Shadow 1 Threshold", Range(0.0, 1.0)) = 0.5
        _Shadow2 ("Shadow 2", Color) = (0.2, 0.2, 0.3, 1.0)
        _ShadowThreshold2 ("Shadow 2 Threshold", Range(0.0, 1.0)) = 0.2
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
            float4 _Shadow1;
            float4 _Shadow2;
            float _ShadowThreshold1;
            float _ShadowThreshold2;

            float gray (fixed3 f) {
                return f.r * 0.3 + f.g * 0.6 + f.b * 0.1;
            }

            v2f vert (appdata_base v)
            {   
                v2f o;
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

                if(gray(i.light) < _ShadowThreshold2) {
                    col *= _Shadow2;
                } else if(gray(i.light) < _ShadowThreshold1) {
                    col *= _Shadow1;
                }

                clip(col.a - 0.5);
                col.rgb += UNITY_LIGHTMODEL_AMBIENT.rgb * 0.2;
                return col;
            }
            ENDCG
        }
    }

    SubShader
    {
        Tags { "RenderType"="TransparentCutout" }
        Pass { }
    }

    FallBack "Diffuse"
}
