//
//  Shaders.metal
//  macmtl
//
//  Created by Tim Gymnich on 14.01.18.
//  Copyright © 2018 Tim Gymnich. All rights reserved.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

// Structure shared between shader and C code to ensure the layout of shared uniform data accessed in
//    Metal shaders matches the layout of uniform data set in C code
typedef struct {
    // Camera Uniforms
    matrix_float4x4 projectionMatrix;
    float projectionMatrix4D[25];
    matrix_float4x4 viewMatrix;
} SharedUniforms;

// Structure shared between shader and C code to ensure the layout of instance uniform data accessed in
//    Metal shaders matches the layout of uniform data set in C code
typedef struct {
    matrix_float4x4 modelMatrix;
    float modelViewMatrix4D[25];
    
} InstanceUniforms;

static int index(int row, int column)
{
    int columns = 5;
    return (row * columns) + column;
}

typedef struct {
    float2 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
} ImageVertex;


typedef struct {
    float4 position [[position]];
    float2 texCoord;
} ImageColorInOut;

typedef struct {
    float4 position [[attribute(0)]];
    float4 color [[attribute(1)]];
} Vertex;

typedef struct {
    float4 position [[position]];
    float4 color;
} ColorInOut;


// Captured image vertex function
vertex ImageColorInOut capturedImageVertexTransform(ImageVertex in [[stage_in]]) {
    ImageColorInOut out;
    
    // Pass through the image vertex's position
    out.position = float4(in.position, 0.0, 1.0);
    
    // Pass through the texture coordinate
    out.texCoord = in.texCoord;
    
    return out;
}

// Captured image fragment function
fragment float4 capturedImageFragmentShader(ImageColorInOut in [[stage_in]],
                                            texture2d<float, access::sample> capturedImageTextureY [[ texture(1) ]],
                                            texture2d<float, access::sample> capturedImageTextureCbCr [[ texture(2) ]]) {
    
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear);
    
    const float4x4 ycbcrToRGBTransform = float4x4(float4(+1.0000f, +1.0000f, +1.0000f, +0.0000f),
                                                  float4(+0.0000f, -0.3441f, +1.7720f, +0.0000f),
                                                  float4(+1.4020f, -0.7141f, +0.0000f, +0.0000f),
                                                  float4(-0.7010f, +0.5291f, -0.8860f, +1.0000f));
    
    // Sample Y and CbCr textures to get the YCbCr color at the given texture coordinate
    float4 ycbcr = float4(capturedImageTextureY.sample(colorSampler, in.texCoord).r, capturedImageTextureCbCr.sample(colorSampler, in.texCoord).rg, 1.0);
    
    // Return converted RGB color
    return ycbcrToRGBTransform * ycbcr;
}



// Anchor geometry vertex function
vertex ColorInOut anchorGeometryVertexTransform(Vertex in [[stage_in]],
                                                constant SharedUniforms &sharedUniforms [[ buffer(3) ]],
                                                constant InstanceUniforms *instanceUniforms [[ buffer(2) ]],
                                                ushort vid [[vertex_id]],
                                                ushort iid [[instance_id]]) {
    ColorInOut out;
    
    // Make position a float[5] to perform 5x5 matrix math on it
    float position[5] = {in.position.x, in.position.y, in.position.z, in.position.w, 1.0};
    float4x4 modelMatrix = instanceUniforms[iid].modelMatrix;
    float4x4 modelViewMatrix = sharedUniforms.viewMatrix * modelMatrix;
    
    //Matrix multiply
    float matrix_matrix_res[25] = {};
    
    for (int i=0;i<5;i++)
    {
        for (int j=0;j<5;j++)
        {
            for (int k=0;k<5;k++)
            {
                matrix_matrix_res[index(i,j)] += sharedUniforms.projectionMatrix4D[index(i,k)] * instanceUniforms[iid].modelViewMatrix4D[index(k,j)];
            }
        }
    }
    
    //Vector multiply
    float position4D[5] = {};
    
    for (int i=0;i<5;i++)
    {
        for (int j=0;j<5;j++)
        {
            position4D[i] += matrix_matrix_res[i*5+j] * position[j];
        }
    }
    
    // Normalize reduce #1
    float res1[4] = {};
    
    for (int i=0;i<4;i++)
    {
        res1[i] = position4D[i] / position4D[4];
    }
    
    //Normalize reduce #2
    float res2[3] = {};
    
    for (int i=0;i<3;i++)
    {
        res2[i] = res1[i] / res1[3];
    }
    float4 result2 = float4(res2[0],res2[1],res2[2],1);
    
    // Calculate the position of our vertex in clip space and output for clipping and rasterization
    out.position = sharedUniforms.projectionMatrix * modelViewMatrix * result2;
    
    // Color each face a different color
    //                ushort colorID = vid / 4 % 6;
    //                out.color = colorID == 0 ? float4(0.0, 1.0, 0.0, 1.0) // Right face
    //                : colorID == 1 ? float4(1.0, 0.0, 0.0, 1.0) // Left face
    //                : colorID == 2 ? float4(0.0, 0.0, 1.0, 1.0) // Top face
    //                : colorID == 3 ? float4(1.0, 0.5, 0.0, 1.0) // Bottom face
    //                : colorID == 4 ? float4(1.0, 1.0, 0.0, 1.0) // Back face
    //                : float4(1.0, 1.0, 1.0, 1.0); // Front face
    
    out.color = in.color;
    
    return out;
}

// Anchor geometry fragment function
fragment float4 anchorGeometryFragmentLighting(ColorInOut in [[stage_in]], constant SharedUniforms &uniforms [[ buffer(3) ]]) {
    
    return float4(in.color);
}


