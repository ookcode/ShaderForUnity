// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/高光反射Blinn模型"
{
	Properties
	{
		_Diffuse ("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
        _Specular ("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss ("Gloss", Float) = 100.0
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
            fixed4 _Specular;
            float _Gloss;
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 color : Color;
            };
            
			v2f vert (appdata_full v)   
			{
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                
                // 法向量的世界坐标
                fixed3 normal = normalize(UnityObjectToWorldNormal(v.normal));
                
                // 光源向量的世界坐标
                fixed3 light = normalize(_WorldSpaceLightPos0.xyz);
                
                // 漫反射
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(normal, light));  
                
                // 视角向量
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(UnityObjectToWorldDir(v.vertex).xyz));
                
                // 中间向量
                fixed3 middleDir = normalize(light + viewDir);
                
                // 高光反射
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(normal, middleDir)), _Gloss);
                
                o.color = ambient + diffuse + specular;
                
				return o;
			}
			
			fixed4 frag (v2f o) : SV_Target
			{
				return fixed4(o.color, 1.0);
			}
			ENDCG
		}
	}
}
