Shader "RadualBlur"
{
	Properties
	{
		 [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
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
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// 像素到中心点的向量
				fixed2 dir = 0.5 - i.uv;

				// 沿向量采样
				fixed4 sum = tex2D(_MainTex, i.uv - dir*0.01);
				sum += tex2D(_MainTex, i.uv - dir*0.02);
				sum += tex2D(_MainTex, i.uv - dir*0.03);
				sum += tex2D(_MainTex, i.uv - dir*0.05);
				sum += tex2D(_MainTex, i.uv - dir*0.08);
				sum += tex2D(_MainTex, i.uv + dir*0.01);
				sum += tex2D(_MainTex, i.uv + dir*0.02);
				sum += tex2D(_MainTex, i.uv + dir*0.03);
				sum += tex2D(_MainTex, i.uv + dir*0.05);
				sum += tex2D(_MainTex, i.uv + dir*0.08);
				sum *= 0.1;

				return sum;
			}
			ENDCG
		}
	}
}
