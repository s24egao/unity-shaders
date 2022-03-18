Shader "Custom/Glass2"
{
    Properties
    {
        _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _Refraction ("Refraction", Range(0.0, 2.0)) = 0.5
        _Roughness ("Roughness", Range(0.0, 1.0)) = 0.0
        _Scatter ("Scatter", Range(0.0, 1.0)) = 0.0
    }

    SubShader
    {
        Tags { "Queue"="Transparent" }

        GrabPass { }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f
            {
                float4 grabPos : TEXCOORD0;
                float4 refraction : TEXCOORD1;
                float4 pos : SV_POSITION;
            };

            float4 _Color;
            float _Refraction;
            float _Roughness;
            float _Scatter;
            sampler2D _GrabTexture;

            float random(float s) {
                return frac(sin(s * 123.45) * 48763.0);
            }

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.grabPos = ComputeGrabScreenPos(o.pos);
                fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                fixed3 viewDirection = normalize(UnityWorldSpaceViewDir(o.pos));
                o.refraction = 1 - dot(worldNormal, viewDirection);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                i.grabPos += i.refraction * _Refraction;
                float4 col = tex2Dproj(_GrabTexture, i.grabPos);

                if(_Roughness > 0.0) {
                    col = (0.0, 0.0, 0.0, 0.0);
                    float4 samples = (1.0, 1.0, 1.0, 1.0);
                    for(float x = 0; x <= 1.0; x += 0.05) {
                        for(float y = 0; y <= 1.0; y += 0.05) {
                            float4 pos = i.grabPos;
                            pos.xy += (x - 0.5, y - 0.5) * _Roughness;
                            samples += tex2Dproj(_GrabTexture, pos);
                        }
                    }
                    col = samples / 441;
                }

                if(_Scatter > 0.0) {
                    i.grabPos.x += (random(i.grabPos.x) - 0.5) * _Scatter * 0.5;
                    i.grabPos.y += (random(i.grabPos.y) - 0.5) * _Scatter * 0.5;
                    col = tex2Dproj(_GrabTexture, i.grabPos);
                }

                col.a = 1.0;
                col *= _Color;
                return col;
            }
            ENDCG
        }
    }
    
    FallBack "Diffuse"
}
