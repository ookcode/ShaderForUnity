// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/漫反射兰伯特模型2"
{
	Properties
	{
		_Diffuse ("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
	}
	SubShader
	{
		Tags { "LightMode"="ForwardBase" }

		Pass
		{
			CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
			#include "UnityCG.cginc"
            #include "Lighting.cginc"
            
            fixed4 _Diffuse;
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 normal : TEXCOORD0;
            };
            
			v2f vert (appdata_full v)
			{
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // 法向量的世界坐标
                o.normal = normalize(UnityObjectToWorldNormal(v.normal));

				return o;
			}
			
			fixed4 frag (v2f o) : SV_Target
			{
                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                
                // 光源向量的世界坐标
                fixed3 light = normalize(_WorldSpaceLightPos0.xyz);
                
                // 漫反射
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(o.normal, light));
                
				return fixed4(ambient + diffuse, 1.0);
			}
			ENDCG
		}
	}
}
