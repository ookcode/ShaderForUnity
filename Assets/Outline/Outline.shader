Shader "Outline"
{
	Properties
    {
        _OutlineColor("Outline Color", Color) = (1,1,1,1)
        _OutlineStrength("Outline Strength", Range(0, 0.1)) = 0.02
    }

    SubShader
    {
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry"}

        Pass
        {
            Cull Front
            Lighting Off

            CGPROGRAM
            #pragma vertex vertXray
            #pragma fragment fragXray
            
            #include "UnityCG.cginc"

            fixed4 _OutlineColor;
            float _OutlineStrength;

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vertXray(appdata_base v)
            {
                v2f o;
                float4 pos = mul( UNITY_MATRIX_MV, v.vertex);
                float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
                normal.z = -1.0;
                pos = pos + float4(normalize(normal), 0) * _OutlineStrength;
                o.pos = mul(UNITY_MATRIX_P, pos);
                return o;
            }

            fixed4 fragXray(v2f i) : SV_TARGET
            {
                return _OutlineColor;
            }
            ENDCG
        }
    }
}

