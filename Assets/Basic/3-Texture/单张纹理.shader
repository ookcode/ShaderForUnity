// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/单张纹理"
{
	Properties
	{
        _Texture ("Texture", 2D) = "white" {}
		_Diffuse ("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
        _Specular ("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss ("Gloss", Float) = 20.0
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
            
            sampler2D _Texture;
            float4 _Texture_ST;
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };
            
			v2f vert (appdata_full v)   
			{
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);

                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));

                o.worldPos = UnityObjectToWorldDir(v.vertex).xyz;
              
                //o.uv = v.texcoord.xy + _Texture_ST.xy + _Texture_ST.zw;
                o.uv = TRANSFORM_TEX(v.texcoord, _Texture);

				return o;
			}
			
			fixed4 frag (v2f o) : SV_Target
			{
                // 纹理颜色
                fixed3 albedo = tex2D(_Texture, o.uv).rgb;

                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                
                // 光源向量的世界坐标
                fixed3 light = normalize(_WorldSpaceLightPos0.xyz);
                
                // 漫反射
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(o.worldNormal, light)) * albedo;  
                
                // 视角向量
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(o.worldPos));
                
                // 中间向量
                fixed3 middleDir = normalize(light + viewDir);
                
                // 镜面反射
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(o.worldNormal, middleDir)), _Gloss);
             
				return fixed4(ambient + diffuse + specular, 1.0);
			}
			ENDCG
		}
	}
}
