// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Standard+XRay"
{
    Properties
    {
        _XRayColor("XRay Color", Color) = (1,1,1,1)
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo", 2D) = "white" {}
        _BumpMap("Normal Map", 2D) = "bump" {}
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
        _Specular("Specular", Color) = (1,1,1,1)
        _SpecularMask("Specular Mask", 2D) = "white" {}
        _Gloss("Gloss", Range(8, 256)) = 20
    }

    SubShader
    {
        Tags { "LightMode"="ForwardBase"}

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

        pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            
            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _BumpMap;
            float4 _BumpMap_ST;

            sampler2D _SpecularMask;
            float4 _SpecularMask_ST;
            
            fixed4 _Specular;
            fixed4 _Diffuse;
            float _Gloss;

            struct v2f {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            v2f vert(appdata_full v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap); // 使用zw来储存切线，纹理坐标相同

                // 模型空间到切线空间的变换
                TANGENT_SPACE_ROTATION;

                // 切线空间下的光源向量和视角向量
                o.lightDir = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)).xyz);
                o.viewDir = normalize(mul(rotation, ObjSpaceViewDir(v.vertex)).xyz);
                
                return o;
            }

            fixed4 frag(v2f o) : SV_TARGET {
                // 切线空间下的法线
                fixed4 packedNormal = tex2D(_BumpMap, o.uv.zw);
                fixed3 tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                // 纹理颜色
                fixed3 albedo = tex2D(_MainTex, o.uv.xy).rgb;

                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                
                // 光源向量的世界坐标
                fixed3 light = normalize(_WorldSpaceLightPos0.xyz);
                
                // 漫反射
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(tangentNormal, o.lightDir)) * albedo;  

                // 中间向量
                fixed3 middleDir = normalize(o.lightDir + o.viewDir);

                // 镜面反射贴图
                fixed specularMask = tex2D(_SpecularMask, o.uv).r;
                
                // 镜面反射
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal, middleDir)), _Gloss) * specularMask;
				
                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
}