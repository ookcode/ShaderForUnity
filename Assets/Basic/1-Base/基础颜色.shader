// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/基础颜色"
{
	Properties
	{
        _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}
	SubShader
	{      
		Pass
		{
			CGPROGRAM
            
			#pragma vertex vert
			#pragma fragment frag
            #include "UnityCG.cginc"
            
            fixed4 _Color;
            
			float4 vert (float4 vert : POSITION): SV_POSITION
			{
				return UnityObjectToClipPos(vert);
			}
			
			fixed4 frag () : SV_Target
			{
				return _Color;
			}
            
			ENDCG
		}
	}
}
