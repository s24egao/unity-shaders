// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Glass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR] _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _Reflection ("Reflection", Range(0.0, 1.0)) = 1.0
        _Refraction ("Refraction", Range(0.0, 2.0)) = 0.5
        _RGBSeparate ("RGB Seperate", Range(0.0, 0.5)) = 0.0
        _Roughness ("Roughness", Range(0.0, 1.0)) = 0.0
        _Scatter ("Scatter", Range(0.0, 1.0)) = 0.0
    }

    SubShader
    {
        Tags { "Queue"="Transparent" }

        GrabPass
        {
            "_BackgroundTexture"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 viewDirection : TEXCOORD2;
                float4 grabPos : TEXCOORD3;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _Color;
            float _Reflection;
            float _Refraction;
            float _RGBSeparate;
            float _Roughness;
            float _Scatter;
            sampler2D _BackgroundTexture;

            float random(float s)
            {
                return frac(sin(s * 123.45) * 48763.0);
            }

            float4 tex2DprojRGB(sampler2D tex, float4 pos, float4 refraction, float amount)
            {
                float r = tex2Dproj(tex, pos + refraction * _Refraction * (1 - amount)).r;
                float g = tex2Dproj(tex, pos + refraction * _Refraction).g;
                float b = tex2Dproj(tex, pos + refraction * _Refraction * (1 + amount)).b;
                return float4(r, g, b, 1.0);
            }

            float gray (float3 f)
            {
                return f.r * 0.3 + f.g * 0.6 + f.b * 0.1;
            }

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.grabPos = ComputeGrabScreenPos(o.pos);
                o.uv = v.texcoord;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDirection = UnityWorldSpaceViewDir(o.pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 refraction = 1 - dot(normalize(i.worldNormal), normalize(i.viewDirection));
                float4 background = tex2DprojRGB(_BackgroundTexture, i.grabPos, refraction, _RGBSeparate);

                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 viewDirection = normalize(i.viewDirection);
                fixed3 light = max(0.0, pow(dot(worldNormal, worldLight), 50.0) * 2.0);

                float4 col = (1.0, 1.0, 1.0, 1.0);

                if(_Reflection > 0.0) {
                    half3 worldReflection = reflect(-viewDirection, worldNormal);
                    half4 skydata = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldReflection);
                    half3 skycolor = DecodeHDR (skydata, unity_SpecCube0_HDR);
                    skycolor = lerp(float3(1.0, 1.0, 1.0), skycolor, _Reflection);
                    if(gray(light) > gray(skycolor)) skycolor = light;
                    col.rgb *= skycolor;
                }

                float alpha = max(min(pow((1 - abs(dot(worldNormal, viewDirection))), 2.0) * 2.0, 1.0), light);
                if(alpha < 1.0) col.rgb = lerp(background.rgb, col.rgb, alpha);

                if(_Roughness > 0.0) {
                    float4 samples = (1.0, 1.0, 1.0, 1.0);
                    for(float x = 0; x <= 1.0; x += 0.05) {
                        for(float y = 0; y <= 1.0; y += 0.05) {
                            float4 pos = i.grabPos;
                            pos.x += (x - 0.5) * _Roughness * 0.5;
                            pos.y += (y - 0.5) * _Roughness * 0.5;
                            samples += tex2DprojRGB(_BackgroundTexture, pos, refraction, _RGBSeparate);
                        }
                    }
                    col = lerp(samples / 441, col, alpha);
                }

                if(_Scatter > 0.0) {
                    i.grabPos.x += (random(i.grabPos.x) - 0.5) * _Scatter * 0.5;
                    i.grabPos.y += (random(i.grabPos.y) - 0.5) * _Scatter * 0.5;
                    col = lerp(tex2DprojRGB(_BackgroundTexture, i.grabPos, refraction, _RGBSeparate), col, alpha);
                }

                col *= tex2D(_MainTex, i.uv);
                col *= _Color;

                return col;
            }
            ENDCG
        }

        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
