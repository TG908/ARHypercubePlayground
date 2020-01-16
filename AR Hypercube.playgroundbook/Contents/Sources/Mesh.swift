//
//  Mesh.swift
//  macmtl
//
//  Created by Tim Gymnich on 20.03.18.
//  Copyright © 2018 Tim Gymnich. All rights reserved.
//

import Metal


public class Mesh {
    
    public var vertexCount: Int
    public var vertexBuffer: MTLBuffer
    public var primitiveType: MTLPrimitiveType
    public var device: MTLDevice
    
    
    public init (vertexBuffer: MTLBuffer, vertexCount: Int, primitiveType: MTLPrimitiveType, device: MTLDevice) {
        self.vertexCount =  vertexCount
        self.vertexBuffer = vertexBuffer
        self.primitiveType = primitiveType
        self.device = device
    }
}
