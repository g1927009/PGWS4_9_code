Shader "Custom/My Best Shader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "black" {}
        _Color("Color", Color) = (0,0,0,1)
        _RimColor("RimColor", Color) = (1,0,0,1)
        _RimPower("RimPower", float) = 1.0
    }
        SubShader
        {
            Tags {"RenderType" = "Opaque" }
            LOD 100

            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "UnityCG.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                float3 normal : NORMAL;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                    float3 viewDir : TEXCOORD1;
                    float3 normalDir : TEXCOORD2;
                };

                sampler2D _MainTex;
                fixed4 _MainTex_ST;
                fixed4 _Color;
                fixed4 _RimColor;
                half _RimPower;

                v2f vert(appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    float4x4 modelMatrix = unity_ObjectToWorld;
                    o.normalDir = normalize(UnityObjectToWorldNormal(v.normal));
                    o.viewDir = normalize(_WorldSpaceCameraPos - mul(modelMatrix, v.vertex).xyz);
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    fixed4 col = tex2D(_MainTex, i.uv) * _Color;

                    half rim = 1.0 - abs(dot(i.viewDir, i.normalDir));
                    fixed3 emission = _RimColor.rgb * pow(rim, _RimPower) * _RimPower;
                    col.rgb += emission;
                    col = fixed4(col.rgb, 1.0);
                    return col;
                }
                ENDCG
            }
        }
}
