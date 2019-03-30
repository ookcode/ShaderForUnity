// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/凹凸映射-切线空间"
{
	Properties
	{
        _Texture ("Texture", 2D) = "white" {}
        _BumpMap("Normal Map", 2D) = "bump" {}
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

            sampler2D _BumpMap;
            float4 _BumpMap_ST;

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0; // 全部转化为切线空间下的方向
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };
            
			v2f vert (appdata_full v)   
			{
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);

                //o.uv = v.texcoord.xy + _Texture_ST.xy + _Texture_ST.zw;
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _Texture);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap); // 使用zw来储存切线，纹理坐标相同

                // 模型空间到切线空间的变换
                //float3 dinormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
                //float3x3 rotation = float3x3(v.tangent.xyz, dinormal, v.normal);
                TANGENT_SPACE_ROTATION;

                // 切线空间下的光源向量和视角向量
                o.lightDir = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)).xyz);
                o.viewDir = normalize(mul(rotation, ObjSpaceViewDir(v.vertex)).xyz);
            
				return o;
			}
			
			fixed4 frag (v2f o) : SV_Target
			{
                // 切线空间下的法线
                fixed4 packedNormal = tex2D(_BumpMap, o.uv.zw);
                fixed3 tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                // 纹理颜色
                fixed3 albedo = tex2D(_Texture, o.uv.xy).rgb;

                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                
                // 光源向量的世界坐标
                fixed3 light = normalize(_WorldSpaceLightPos0.xyz);
                
                // 漫反射
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(tangentNormal, o.lightDir)) * albedo;  

                // 中间向量
                fixed3 middleDir = normalize(o.lightDir + o.viewDir);
                
                // 镜面反射
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal, middleDir)), _Gloss) * albedo;
             
				return fixed4(ambient + diffuse + specular, 1.0);
			}
			ENDCG
		}
	}
}
