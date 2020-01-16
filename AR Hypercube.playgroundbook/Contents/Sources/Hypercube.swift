//
//  Hypercube.swift
//  macmtl
//
//  Created by Tim Gymnich on 20.03.18.
//  Copyright © 2018 Tim Gymnich. All rights reserved.
//

import Metal
import simd

struct Vertex4D {
    var position: vector_float4
    var color: vector_float4
}

public class Hypercube: Mesh {
    
    public init(primitiveType: MTLPrimitiveType = .triangle, wireframe: Bool, device: MTLDevice) throws {
        
        
        //Create Vertex Array
        /*
         
         L_______________K
         |\ .            |\ .
         | \   .         | \   .
         |  \     .      |  \     .
         |   \       D_______\_______C
         |    I______|\______ J      |\
         |    |  .   | \ |    |  .   | \
         |    |     .|  \|    |     .|  \
         P_______________O    |      | . \
         \ . |      |    A___|______|____B
          \  |.     |    |   |.     |    |
           \ |   .  |    |   |   .  |    |
            \|      H____|___|______G    |
             M_______\_______N       \   |
                .     \  |      .     \  |
                   .   \ |         .   \ |
                      . \|            . \|
                         E_______________F
         */
        
        
        let A = Vertex4D(position: float4(-1,-1,1,-1),  color: float4(1,0,0,1))
        let B = Vertex4D(position: float4(1,-1,1,-1), color: float4(1,0,0,1))
        let C = Vertex4D(position: float4(1,1,1,-1),  color: float4(1,0,0,1))
        let D = Vertex4D(position: float4(-1,1,1,-1),   color: float4(1,0,0,1))
        let E = Vertex4D(position: float4(-1,-1,-1,-1), color: float4(1,0,0,1))
        let F = Vertex4D(position: float4(1,-1,-1,-1),color: float4(1,0,0,1))
        let G = Vertex4D(position: float4(1,1,-1,-1), color: float4(1,0,0,1))
        let H = Vertex4D(position: float4(-1,1,-1,-1),  color: float4(1,0,0,1))
        let I = Vertex4D(position: float4(-1,-1,1,1),  color: float4(0,1,0,1))
        let J = Vertex4D(position: float4(1,-1,1,1), color: float4(0,1,0,1))
        let K = Vertex4D(position: float4(1,1,1,1),  color: float4(0,1,0,1))
        let L = Vertex4D(position: float4(-1,1,1,1),   color: float4(0,1,0,1))
        let M = Vertex4D(position: float4(-1,-1,-1,1), color: float4(0,1,0,1))
        let N = Vertex4D(position: float4(1,-1,-1,1),color: float4(0,1,0,1))
        let O = Vertex4D(position: float4(1,1,-1,1), color: float4(0,1,0,1))
        let P = Vertex4D(position: float4(-1,1,-1,1),  color: float4(0,1,0,1))
        
        
        let meshModel: [Vertex4D] = [
            A,D,B,
            A,D,E,
            A,D,I,
            A,E,I,
            A,E,B,
            A,I,B,
            M,E,P,
            M,E,N,
            M,E,I,
            M,I,N,
            M,I,P,
            M,N,P,
            H,D,G,
            H,D,P,
            H,D,E,
            H,E,G,
            H,E,P,
            H,P,G,
            L,D,K,
            L,D,I,
            L,D,P,
            L,P,K,
            L,P,I,
            L,K,I,
            O,P,G,
            O,P,K,
            O,P,N,
            O,G,N,
            O,G,K,
            O,N,K,
            C,D,B,
            C,D,K,
            C,D,G,
            C,B,K,
            C,B,G,
            C,G,K,
            J,I,K,
            J,I,B,
            J,I,N,
            J,K,B,
            J,K,N,
            J,B,N,
            F,E,G,
            F,E,B,
            F,E,N,
            F,B,N,
            F,B,G,
            F,N,G,
            ]
        
        let wireFrameModel = [
            A,I,
            I,M,
            M,E,
            E,A,
            A,D,
            I,L,
            M,P,
            E,H,
            D,H,
            D,L,
            L,P,
            H,P,
            D,C,
            H,G,
            E,F,
            A,B,
            M,N,
            P,O,
            I,J,
            L,K,
            K,C,
            C,G,
            G,O,
            K,O,
            K,J,
            O,N,
            C,B,
            G,F,
            J,B,
            B,F,
            F,N,
            N,J
        ]
        
        var model: [Vertex4D] = []
        
        if wireframe {
            model = wireFrameModel.pairs().flatMap { Hypercube.createLine((lhs: $0.0, rhs: $0.1!)) }
        } else {
            model = meshModel
        }
        
        let vertexCount = model.count
        
        
        var vertexData = Array<Float>()
        for vertex in model {
            vertexData += [vertex.position.x, vertex.position.y, vertex.position.z, vertex.position.w, vertex.color.x, vertex.color.y, vertex.color.z, vertex.color.w]
        }
        
        let vertexBuffer = device.makeBuffer(bytes: vertexData, length: vertexCount*32, options: [MTLResourceOptions.storageModeShared])!
        vertexBuffer.label = "HypercubeVertexBuffer"
        
        super.init(vertexBuffer: vertexBuffer, vertexCount: vertexCount, primitiveType: primitiveType, device: device)
    }
    
    static func createLine(_ points: (lhs: Vertex4D, rhs: Vertex4D), thickness: Float = 0.1) -> [Vertex4D] {
        
        /*
            B-------C
           /|      /|            Z
          / |     / |            |
         A--|----D  |            |___X
         |  F----|--G           /
         | /     | /           Y
         E-------H
         */
        
        let halfThickness = thickness * 0.5
        
        
        let A = Vertex4D(position: points.lhs.position.sigModify(-halfThickness), color: points.lhs.color)
        let B = Vertex4D(position: points.lhs.position.sigModify(-halfThickness), color: points.lhs.color)
        let C = Vertex4D(position: points.lhs.position.sigModify(halfThickness), color: points.lhs.color)
        let D = Vertex4D(position: points.lhs.position.sigModify(halfThickness), color: points.lhs.color)
        let E = Vertex4D(position: points.rhs.position.sigModify(-halfThickness), color: points.rhs.color)
        let F = Vertex4D(position: points.rhs.position.sigModify(-halfThickness), color: points.rhs.color)
        let G = Vertex4D(position: points.rhs.position.sigModify(halfThickness), color: points.rhs.color)
        let H = Vertex4D(position: points.rhs.position.sigModify(halfThickness), color: points.rhs.color)
        
        return [
            A,D,E,   //front
            H,D,E,
            
            B,F,C,   //back
            F,C,G,
            
            A,E,F,   //left
            F,B,A,
            
            D,H,G,   //right
            D,C,G,
            
            A,B,D,   //top
            C,B,D,
            
            F,E,H,   //bottom
            G,F,H,
        ]
    }
    
}

extension float4 {
    
    func sigModify(_ modifier: Float = 0.05) -> float4 {
        return float4(self.x + sign(self.x) * modifier, self.y + sign(self.y) * modifier, self.z + sign(self.z) * modifier, self.w)
    }
    
}

extension Array {
    
    func pair(index i: Index) -> (Element, Element?) {
        return (self[i], i < self.count - 1 ? self[i+1] : nil)
    }
    
    func pairs() -> [(Element, Element?)] {
        var result = [(Element, Element?)]()
        for i in 0..<self.count/2 {
            result.append(self.pair(index: 2*i))
        }
        return result
    }
}


