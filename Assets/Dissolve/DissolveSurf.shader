Shader "DissolveSurf"
{
	Properties
	{
        _MainTex("Albedo", 2D) = "white" {}
        _Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
        _SpecGlossMap("Specular", 2D) = "white" {}
        _BumpMap("Normal Map", 2D) = "bump" {}
        
        _DissolveMap("DissolveMap", 2D) = "white" {}
        _DissolveThreshold("DissolveThreshold", Range(0, 1)) = 0
        _DissolveColorA("Dissolve Color A", Color) = (0, 0, 0, 0)
        _DissolveColorB("Dissolve Color B", Color) = (1, 1, 1, 1)
        _ColorFactorA("ColorFactorA", Range(0, 1)) = 0.7
        _ColorFactorB("ColorFactorB", Range(0, 1)) = 0.8
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }  
        CGPROGRAM            
        #pragma surface surf StandardSpecular fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _SpecGlossMap;
        sampler2D _BumpMap;
        float _Glossiness;

        sampler2D _DissolveMap;
        float4 _DissolveMap_ST;
        float _DissolveThreshold;
        float _ColorFactorA;
        float _ColorFactorB;
        fixed4 _DissolveColorA;
        fixed4 _DissolveColorB;

        /*
        https://docs.unity3d.com/Manual/SL-SurfaceShaders.html
        struct Input
        {
            float2 uv_XXTexName; // 使用uv+纹理名称
            float3 viewDir; // 包含视图方向，用于计算视差效果，边框照明等
            float4 screenPos; // 包含反射或屏幕空间效果的屏幕空间位置
            float3 worldPos;  // 包含世界空间位置
            float3 worldRefl; // 如果表面着色器不写入o.Normal，则包含世界反射向量。例如，请参见反射 - 漫反射着色器。
            float3 worldNormal; // 如果表面着色器不写入o.Normal，则包含世界法线向量。
            ...
        }
        */
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float2 uv_SpecGlossMap;
        };
        
        /*
        https://docs.unity3d.com/Manual/SL-SurfaceShaders.html
        struct SurfaceOutputStandardSpecular
        {
            fixed3 Albedo;      // diffuse color
            fixed3 Specular;    // specular color
            fixed3 Normal;      // tangent space normal, if written
            half3 Emission;
            half Smoothness;    // 0=rough, 1=smooth
            half Occlusion;     // occlusion (default 1)
            fixed Alpha;        // alpha for transparencies
        };
        */  
        void surf (Input IN, inout SurfaceOutputStandardSpecular o)
        {
            fixed4 dissolveValue = tex2D(_DissolveMap, IN.uv_MainTex);
            if(dissolveValue.r < _DissolveThreshold) {
                discard;
            }

            fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
            fixed4 norTex = tex2D(_BumpMap, IN.uv_BumpMap);
            fixed4 spTex = tex2D(_SpecGlossMap, IN.uv_SpecGlossMap);
            o.Albedo = tex.rgb;

            float lerpValue = _DissolveThreshold / dissolveValue.r;
            if(lerpValue > _ColorFactorA) {
                if(lerpValue > _ColorFactorB) {
                    o.Albedo = _DissolveColorB;
                } else {
                    o.Albedo = _DissolveColorA;
                }
            }

            o.Alpha = tex.a;
            o.Normal = UnpackNormal(norTex);
            o.Specular = spTex;
            o.Smoothness = _Glossiness * spTex.a;
        }
        ENDCG
	}
}
