
static float EdgeScale = 0.1;
float3   CameraPosition    : POSITION  < string Object = "Camera"; >;
float4x4 LightWorldViewProjMatrix : WORLDVIEWPROJECTION < string Object = "Light"; >;
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4x4 WorldMatrix              : WORLD;
float4x4 ViewMatrix               : VIEW;


texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

texture ObjectSphereMap: MATERIALSPHEREMAP;
sampler ObjSphareSampler = sampler_state {
    texture = <ObjectSphereMap>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);
sampler DefSampler : register(s0);

struct BufferShadow_OUTPUT {
    float4 Pos      : POSITION;    
    float4 ZCalcTex : TEXCOORD0;   
    float2 Tex      : TEXCOORD1;   
    float3 Normal   : TEXCOORD2;   
    float3 Eye      : TEXCOORD3;  
    float2 SpTex    : TEXCOORD4;	
    float4 Color    : COLOR0;     
};


BufferShadow_OUTPUT BufferShadow_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0)
{
    BufferShadow_OUTPUT Out = (BufferShadow_OUTPUT)0;


    Out.Pos = mul( Pos, WorldViewProjMatrix );
    

    Out.Eye = CameraPosition - mul( Pos, WorldMatrix );

    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );

    Out.ZCalcTex = mul( Pos, LightWorldViewProjMatrix );
    

    Out.Tex = Tex;
    
    return Out;
}


float4 BufferShadow_PS(BufferShadow_OUTPUT IN) : COLOR
{
 return float4(1,1,1,1);
}

BufferShadow_OUTPUT BufferShadow_VS2(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0)
{
    BufferShadow_OUTPUT Out = (BufferShadow_OUTPUT)0;

	float len = length(CameraPosition - mul(Pos,WorldMatrix));
	EdgeScale *= len*0.01;

	Pos.xyz += normalize(Normal)*EdgeScale;


    Out.Pos = mul( Pos, WorldViewProjMatrix );
    

    Out.Eye = CameraPosition - mul( Pos, WorldMatrix );

    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );

    Out.ZCalcTex = mul( Pos, LightWorldViewProjMatrix );

    Out.Tex = Tex;
    
    return Out;
}


float4 BufferShadow_PS2(BufferShadow_OUTPUT IN) : COLOR
{

 return float4(0,0,0,1);
}

technique MainTecBS0  < string MMDPass = "object_ss"; string Script = 
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=DrawObject2;"
	    "Pass=DrawObject;"
    ;
 >{
     pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS();
        PixelShader  = compile ps_3_0 BufferShadow_PS();
    }
     pass DrawObject2 {
     	CULLMODE = CW;
        VertexShader = compile vs_3_0 BufferShadow_VS2();
        PixelShader  = compile ps_3_0 BufferShadow_PS2();
    }
}

