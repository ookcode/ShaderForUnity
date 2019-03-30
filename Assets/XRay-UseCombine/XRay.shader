Shader "XRay"
{
	Properties
    {
        _XRayColor("XRay Color", Color) = (1,1,1,1)
    }

    SubShader
    {
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry+10"}

        Pass
        {
            Blend SrcAlpha One
            ZTest Greater
            ZWrite Off
            Cull Back

            CGPROGRAM
            #pragma vertex vertXray
            #pragma fragment fragXray
            
            #include "UnityCG.cginc"

            fixed4 _XRayColor;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                float3 viewDir : TEXCOORD0;
                fixed4 clr : COLOR;
            };

            v2f vertXray(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.viewDir = ObjSpaceViewDir(v.vertex);
                o.normal = v.normal;

                float3 normal = normalize(v.normal);
                float3 viewDir = normalize(o.viewDir);
                float rim = 1 - dot(normal, viewDir);

                o.clr = _XRayColor * rim;
                return o;
            }

            fixed4 fragXray(v2f i) : SV_TARGET
            {
                return i.clr;
            }
            ENDCG
        }
    }
}

