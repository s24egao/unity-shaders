Shader "Custom/Glass1"
{
    Properties
    {
        _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _Reflection ("Reflection", Range(0.0, 1.0)) = 1.0 
    }

    SubShader
    {
        Tags { "Queue"="Transparent" }

        Pass
        {
            Cull Off
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct v2f
            {
                float3 worldNormal : TEXCOORD0;
                float3 viewDirection : TEXCOORD1;
                float4 pos : SV_POSITION;
            };

            float4 _Color;
            float _Reflection;

            float gray (float3 f) {
                return f.r * 0.3 + f.g * 0.6 + f.b * 0.1;
            }

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDirection = UnityWorldSpaceViewDir(o.pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 viewDirection = normalize(i.viewDirection);
                fixed3 light = max(0.0, pow(dot(worldNormal, worldLight), 50.0) * 2.0);

                float4 col = _Color;

                if(_Reflection > 0.0) {
                    half3 worldReflection = reflect(-viewDirection, worldNormal);
                    half4 skydata = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldReflection);
                    half3 skycolor = DecodeHDR (skydata, unity_SpecCube0_HDR);
                    skycolor = lerp(float3(1.0, 1.0, 1.0), skycolor, _Reflection);
                    if(gray(light) > gray(skycolor)) skycolor = light;
                    col.rgb *= skycolor;
                }

                col.a = max(min(pow((1 - abs(dot(worldNormal, viewDirection))), 2.0) * 2.0, 1.0), light);
                return col;
            }
            ENDCG
        }

        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
