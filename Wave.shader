Shader "Custom/Wave"
{
    Properties
    {
        _Amount ("Amount", Range(0.0, 10.0)) = 1.0
        _Size ("Size", Range(0.0, 10.0)) = 1.0
        _Speed ("Speed", Range(0.0, 10.0)) = 1.0
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

            float _Amount;
            float _Size;
            float _Speed;
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
                i.grabPos /= i.grabPos.w;
                i.grabPos.x += sin(i.grabPos.y * 100.0 / _Size + _Time * 100.0 * _Speed) * 0.1 * _Amount;
                fixed4 col = tex2D(_GrabTexture, i.grabPos);
                return col;
            }
            ENDCG
        }
    }

    Fallback "Diffuse"
}
