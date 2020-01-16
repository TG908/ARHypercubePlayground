//
//  ShaderTypes.h
//
//  Created by Tim Gymnich on 14.03.18.
//  Copyright © 2018 Tim Gymnich. All rights reserved.
//

//
// An atempt to replace the missing Bridging-Header
//
import simd

typealias matrix_array_float5x5 = (Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float)

// Buffer index values shared between shader and C code to ensure Metal shader buffer inputs match
//   Metal API buffer set calls
enum BufferIndices: Int {
    case MeshPositions      = 0
    case MeshGenerics       = 1
    case InstanceUniforms   = 2
    case SharedUniforms     = 3
}

// Attribute index values shared between shader and C code to ensure Metal shader vertex
//   attribute indices match the Metal API vertex descriptor attribute indices
enum VertexAttributes: Int {
    case Position = 0
    case Color = 1
}

// Texture index values shared between shader and C code to ensure Metal shader texture indices
//   match indices of Metal API texture set calls
enum TextureIndices: Int {
    case Color = 0
    case IndexY = 1
    case CbCr = 2
}

// Structure shared between shader and C code to ensure the layout of shared uniform data accessed in
//    Metal shaders matches the layout of uniform data set in C code
struct SharedUniforms {
    var projectionMatrix: matrix_float4x4
    var projectionMatrix4D: matrix_array_float5x5
    var viewMatrix: matrix_float4x4
}

// Structure shared between shader and C code to ensure the layout of instance uniform data accessed in
//    Metal shaders matches the layout of uniform data set in C code
struct InstanceUniforms {
    var modelMatrix: matrix_float4x4
    var modelViewMatrix4D: matrix_array_float5x5
}



