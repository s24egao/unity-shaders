Shader "Custom/Pixel"
{
    Properties
    {
        _Resolution ("Resolution", Range(2.0, 512.0)) = 200.0
        _Posterize ("Posterize", Range(2.0, 512.0)) = 16.0
        _Scale ("Scale Resulution With Distance", Range(0.0, 1.0)) = 0.0
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
                float4 pos : SV_POSITION;
            };

            float _Resolution;
            float _Posterize;
            float _Scale;
            sampler2D _GrabTexture;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.grabPos = ComputeGrabScreenPos(o.pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                _Resolution *= floor(i.pos.w * _Scale) + 1.0;
                float aspect = _ScreenParams.y / _ScreenParams.x;
                i.grabPos /= i.grabPos.w;
                i.grabPos.x = floor(i.grabPos.x * _Resolution + 0.5) / _Resolution;
                i.grabPos.y = floor(i.grabPos.y * _Resolution * aspect + 0.5) / (_Resolution * aspect);
                fixed4 col = tex2D(_GrabTexture, i.grabPos);
                col.rgb = floor(col.rgb * _Posterize) / _Posterize;
                return col;
            }
            ENDCG
        }
    }

    Fallback "Diffuse"
}
