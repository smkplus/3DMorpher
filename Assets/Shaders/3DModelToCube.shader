Shader "Unlit/3DModelToCube"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Blend("Blend",Range(0,1)) = 0
		_Size("Size",Float) = 0
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
				float3 normal :NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Blend;
			 float _Size;
			
			v2f vert (appdata v)
			{
				v2f o;

				float3 anotherShape;

				// CUBE
					// We can determine the face of the cube to which we belong
					// by which component is furthest from zero
					// (this divides 3D space into 6 pyramids)
					float3 absolute = abs(v.vertex.xyz);
					float greatest = max(absolute.x, max(absolute.y, absolute.z));

					// Dividing by this greatest value snaps the vertex to one of the planes
					// x = 1, y = 1, z = 1, x = -1, y = -1, or z = -1, ie. the unit cube.
					// Scaling by a _Size parameter makes the cube however big we want it.
					anotherShape = v.vertex.xyz * _Size / greatest; 

				

				// Perform our blend in object space, before projection.
				float4 blended = float4(lerp(v.vertex.xyz, anotherShape, _Blend), 1.0f);

				// Project our blended result to clip space. 
				o.vertex = UnityObjectToClipPos(blended);

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
