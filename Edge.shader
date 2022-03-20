Shader "Custom/Edge"
{
    Properties
    {
        _Edge ("Edge", Range(0.0, 1.0)) = 1.0
        _Depth ("Depth", Range(0.0, 1.0)) = 1.0
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

            float _Edge;
            float _Depth;
            sampler2D _CameraDepthTexture;
            float4 _CameraDepthTexture_TexelSize;

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
                float4 col = tex2D(_CameraDepthTexture, i.grabPos);
                float up = tex2D(_CameraDepthTexture, i.grabPos + float4(0.0, _CameraDepthTexture_TexelSize.y, 0.0, 0.0));
                float down = tex2D(_CameraDepthTexture, i.grabPos + float4(0.0, -_CameraDepthTexture_TexelSize.y, 0.0, 0.0));
                float left = tex2D(_CameraDepthTexture, i.grabPos + float4(-_CameraDepthTexture_TexelSize.x, 0.0, 0.0, 0.0));
                float right = tex2D(_CameraDepthTexture, i.grabPos + float4(_CameraDepthTexture_TexelSize.x, 0.0, 0.0, 0.0));
                
                return (col * 100.0) * _Depth + (sqrt(pow(up - down, 2.0) + pow(left - right, 2.0)) * _Edge) * 100.0;
            }
            ENDCG
        }
    }

    Fallback "Diffuse"
}
