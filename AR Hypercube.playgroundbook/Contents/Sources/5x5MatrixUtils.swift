//
//  5x5MatrixUtils.swift
//
//  Created by Tim Gymnich on 28.03.18.
//  Copyright © 2018 Tim Gymnich. All rights reserved.
//

import Foundation

// Keeping it simple to make it easier to work with in metal
struct matrix_float5x5 {
    var data: [Float]
    
    // Fixed size C Array are represented as tupels in Swift
    func cArray() -> matrix_array_float5x5 {
        let a = self.data
        assert(a.count == 25)
        return (a[0],a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],a[10],a[11],a[12],a[13],a[14],a[15],a[16],a[17],a[18],a[19],a[20],a[21],a[22],a[23],a[24])
    }
    
    static func rotation(radians t: Float, plane: Plane4D) -> matrix_float5x5 {
        
        switch plane {
        case .XY:
            return matrix_float5x5(data: [cosf(t),sinf(t),0.0,0.0,0.0,
                                          -sinf(t),cosf(t),0.0,0.0,0.0,
                                          0.0,0.0,1.0,0.0,0.0,
                                          0.0,0.0,0.0,1.0,0.0,
                                          0.0,0.0,0.0,0.0,1.0])
        case .YZ:
            return matrix_float5x5(data: [1.0,0.0,0.0,0.0,0.0,
                                          0.0,cosf(t),sinf(t),0.0,0.0,
                                          0.0,-sinf(t),cosf(t),0.0,0.0,
                                          0.0,0.0,0.0,1.0,0.0,
                                          0.0,0.0,0.0,0.0,1.0])
        case .ZX:
            return matrix_float5x5(data: [cosf(t),0.0,-sinf(t),0.0,0.0,
                                          0.0,1.0,0.0,0.0,0.0,
                                          sinf(t),0.0,cosf(t),0.0,0.0,
                                          0.0,0.0,0.0,1.0,0.0,
                                          0.0,0.0,0.0,0.0,1.0])
        case .XW:
            return matrix_float5x5(data: [cosf(t),0.0,0.0,sinf(t),0.0,
                                          0.0,1.0,0.0,0.0,0.0,
                                          0.0,0.0,1.0,0.0,0.0,
                                          -sinf(t),0.0,0.0,cosf(t),0.0,
                                          0.0,0.0,0.0,0.0,1.0])
        case .YW:
            return matrix_float5x5(data: [1.0,0.0,0.0,0.0,0.0,
                                          0.0,cosf(t),0.0,-sinf(t),0.0,
                                          0.0,0.0,1.0,0.0,0.0,
                                          0.0,sinf(t),0.0,cosf(t),0.0,
                                          0.0,0.0,0.0,0.0,1.0])
        case .ZW:
            return matrix_float5x5(data: [1.0,0.0,0.0,0.0,0.0,
                                          0.0,1.0,0.0,0.0,0.0,
                                          sinf(t),0.0,cosf(t),0.0,0.0,
                                          0.0,0.0,0.0,1.0,0.0,
                                          0.0,0.0,0.0,0.0,1.0])
            
        default:
            return matrix_float5x5(data: [1.0,0.0,0.0,0.0,0.0,
                                          0.0,1.0,0.0,0.0,0.0,
                                          0.0,0.0,1.0,0.0,0.0,
                                          0.0,0.0,0.0,1.0,0.0,
                                          0.0,0.0,0.0,0.0,1.0])
        }
    }
    
    static func translation(_ translationX: Float, _ translationY: Float, _ translationZ: Float, _ translationW: Float) -> matrix_float5x5 {
        return matrix_float5x5(data: [1.0,0.0,0.0,0.0,translationX,
                                      0.0,1.0,0.0,0.0,translationY,
                                      0.0,0.0,1.0,0.0,translationZ,
                                      0.0,0.0,0.0,1.0,translationW,
                                      0.0,0.0,0.0,0.0,1.0])
    }
    
    static func perspective_4D(fovyRadians fovy: Float) -> matrix_float5x5 {
        let s = 1 / tanf(fovy * 0.5)
        return matrix_float5x5(data: [s,  0.0,0.0,0.0,0.0,
                                      0.0,s  ,0.0,0.0,0.0,
                                      0.0,0.0,s  ,0.0,0.0,
                                      0.0,0.0,0.0,1.0,0.0,
                                      0.0,0.0,0.0,0.0,1.0])
    }
    
    // Helper function to navigate an array representing a 5x5 matrix
    static func index(_ row: Int, _ column: Int) -> Int {
        let columns = 5
        return (row * columns) + column
    }
    
    static func * (_ lhs: matrix_float5x5, _ rhs: matrix_float5x5) -> matrix_float5x5 {
        // TODO: Use Accelerate
        assert(rhs.data.count == 25 && lhs.data.count == 25)
        var res = Array<Float>(repeating: 0.0, count: 25)
        for i in 0..<5 {
            for j in 0..<5 {
                for k in 0..<5 {
                    res[index(i,j)] += lhs.data[index(i,k)] * rhs.data[index(k,j)]
                }
            }
        }
        return matrix_float5x5(data: res)
    }
}
