
//  SCMatrix4.swift
//  InverseKinematicsTest
//
//  Created by Cooper Knaak on 10/13/14.
//  Copyright (c) 2014 Cooper Knaak. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

import Accelerate

public struct SCMatrix4 : CustomStringConvertible {
    /*
    *      Matrices are of this format:
    *      scaleX     .       .        x
    *      .       scaleY     .        y
    *      .       .          scaleZ   z
    *      .       .          .        .
    */
    public let values:[GLfloat]
    
    //Initialization
    public init() {
        self.values =  [1.0, 0.0, 0.0, 0.0,
                        0.0, 1.0, 0.0, 0.0,
                        0.0, 0.0, 1.0, 0.0,
                        0.0, 0.0, 0.0, 1.0]
    }//identity
    
    public init(array:[GLfloat]) {
        
        var mutableArray = array
        for _ in mutableArray.count..<16 {
            mutableArray.append(0.0)
        }//make sure array has 16 elements
        
        self.values = mutableArray
    }//initialize with values
    
    //Convenience
    public init(translation:SCVector3) {
        
        var values:[GLfloat] = [1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0]
        
        values[3 * 4 + 0] = GLfloat(translation.x)
        values[3 * 4 + 1] = GLfloat(translation.y)
        values[3 * 4 + 2] = GLfloat(translation.z)
        
        self.init(array: values)
        /*/
        values[0 * 4 + 3] = GLfloat(translation.x)
        values[1 * 4 + 3] = GLfloat(translation.y)
        values[2 * 4 + 3] = GLfloat(translation.z)
        */
    }//translation
    
    public init(x:CGFloat, y:CGFloat, z:CGFloat=0.0) {
        self.init(translation:SCVector3(xValue: x, yValue: y, zValue: z))
    }//translation (convert to vector)
    
    //Scale
    public init(scale:SCVector3) {
        
        var values:[GLfloat] = [1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0]
        
        values[0] = GLfloat(scale.x)
        values[5] = GLfloat(scale.y)
        values[10] = GLfloat(scale.z)
        
        self.init(array: values)
    }//scale
    
    public init(scaleX:CGFloat, scaleY:CGFloat, scaleZ:CGFloat=1.0) {
        self.init(scale:SCVector3(xValue: scaleX, yValue: scaleY, zValue: scaleZ))
    }//scale (convert to vector)
    
    //Rotation (2D)
    public init(rotation2D:CGFloat) {
        
        var values:[GLfloat] = [1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0]
        
        values[0 * 4 + 0] = GLfloat(+cos(rotation2D))
        values[1 * 4 + 0] = GLfloat(-sin(rotation2D))
        values[0 * 4 + 1] = GLfloat(+sin(rotation2D))
        values[1 * 4 + 1] = GLfloat(+cos(rotation2D))
        
        self.init(array: values)
        /*/
        values[0 * 4 + 0] = GLfloat(+cos(rotation2D))
        values[0 * 4 + 1] = GLfloat(-sin(rotation2D))
        values[1 * 4 + 0] = GLfloat(+sin(rotation2D))
        values[1 * 4 + 1] = GLfloat(+cos(rotation2D))
        */
    }//rotate (in 2D)
    
    public init(translation:CGPoint, rotation:CGFloat, scaleX:CGFloat, scaleY:CGFloat) {
        
        var values:[GLfloat] = [1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0]
        
        let cosine =    cos(rotation)
        let sine =      sin(rotation)
        
        values[0 * 4 + 0] = GLfloat(+scaleX * cosine)
        values[1 * 4 + 0] = GLfloat(-scaleY * sine)
        values[3 * 4 + 0] = GLfloat(translation.x)
        values[0 * 4 + 1] = GLfloat(+scaleX * sine)
        values[1 * 4 + 1] = GLfloat(+scaleY * cosine)
        values[3 * 4 + 1] = GLfloat(translation.y)
        
        self.init(array: values)
    }//initialize
    
    public init(translation:CGPoint, rotation:CGFloat, scaleX:CGFloat, scaleY:CGFloat, anchor:CGPoint, size:CGSize) {
        
        /*  This matrix is calculated using
        *  the combined anchor-scale-rotation-translation
        *  model matrix formula (just multiplying them together)
        *  Hopefully, calculating these values directly
        *  is faster than performing the several matrix multiplications
        */
        
        var values:[GLfloat] = [1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0]
        
        let cosine =    cos(rotation)
        let sine =      sin(rotation)
        let a = -anchor.x * size.width
        let b = -anchor.y * size.height
        
        values[0 * 4 + 0] = GLfloat(+scaleX * cosine)
        values[1 * 4 + 0] = GLfloat(-scaleY * sine)
        values[3 * 4 + 0] = GLfloat(a * scaleX * cosine - b * scaleY * sine + translation.x)
        values[0 * 4 + 1] = GLfloat(+scaleX * sine)
        values[1 * 4 + 1] = GLfloat(+scaleY * cosine)
        values[3 * 4 + 1] = GLfloat(a * scaleX * sine + b * scaleY * cosine + translation.y)
        
        self.init(array: values)
    }//initialize
    /*
    *  Rotation (3D)
    *  NOTE: the given formulae rotate clockwise,
    *  whereas other mathematical functions go counterclockwise,
    *  so I use -angle to get the expected result
    */
    public init(rotate angle:CGFloat, about:SCVector3) {
        
        /* (N = angle)
        *  (<X, Y, Z> = about)
        *  (F = 1.0 - cos(N)
        *  (S = sin(N))
        *  (C = cos(N))
        *  According to http://iphonedevelopment.blogspot.com/2009/06/opengl-es-from-ground-up-part-7_04.html
        *  Rotating about a vector =
        *[ X * X * F + C       X * Y * F - Z * C   X * Z * F + Y * S,   0
        *  Y * X * F + Z * S   Y * Y * F + C       Y * Z * F - X * S,   0
        *  X * Z * F + Y * S   Y * Z * F + X * S   Z * Z * F + C    ,   0,
        *  0                ,  0                ,  0                ,   1]
        *
        *   (It appears that the equation for [0][2] (X * Z * F + Y * S) is incorrect
        *   (According to comparisons with GLKit in Objective-C, the correct
        *   (formula is X * Z * F - Y * S, with the + changed to a -
        */
        
        var values:[GLfloat] = [1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0]
        
        let vector = about.unit()
        let x = GLfloat(vector.x)
        let y = GLfloat(vector.y)
        let z = GLfloat(vector.z)
        let c = GLfloat(cos(-angle))
        let s = GLfloat(sin(-angle))
        let f = GLfloat(1.0 - c)
        
        
        values[0 * 4 + 0] = x * x * f + c
        values[0 * 4 + 1] = x * y * f - z * s
        values[0 * 4 + 2] = x * z * f + y * s
        
        values[1 * 4 + 0] = y * x * f + z * s
        values[1 * 4 + 1] = y * y * f + c
        values[1 * 4 + 2] = y * z * f - x * s
        
        values[2 * 4 + 0] = x * z * f - y * s
        values[2 * 4 + 1] = y * z * f + x * s
        values[2 * 4 + 2] = z * z * f + c
        
        self.init(array: values)
    }
    
    public init(rotation:Rotation) {
        self.init(rotate: rotation.angle, about: rotation.vector)
    }//initialize
    
    public init(rotations:TwoStepRotation) {
        self.init(rotation: rotations.first)
        
        if let second = rotations.second {
            self.rotate(second.angle, about: second.vector)
        }
    }
    
    public init(rotate:Rotation, aroundPoint point:SCVector3) {
        
        let centerMatrix = SCMatrix4(translation: -point)
        let rotateMatrix = SCMatrix4(rotation: rotate)
        let translateMatrix = SCMatrix4(translation: point)
        let finalMatrix = centerMatrix * rotateMatrix * translateMatrix
        
        self.values = finalMatrix.values
    }//initialize
    
    public init(rotateAboutX angle:CGFloat) {
        
        var values:[GLfloat] = [1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0]
        
        let c = GLfloat(cos(-angle))
        let s = GLfloat(sin(-angle))
        
        values[1 * 4 + 1] = +c
        values[1 * 4 + 2] = -s
        values[2 * 4 + 1] = +s
        values[2 * 4 + 2] = +c
        
        self.init(array: values)
    }//initialize
    
    public init(rotateAboutY angle:CGFloat) {
        
        var values:[GLfloat] = [1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0]
        
        let c = GLfloat(cos(-angle))
        let s = GLfloat(sin(-angle))
        
        values[0 * 4 + 0] = +c
        values[0 * 4 + 2] = +s
        values[2 * 4 + 0] = -s
        values[2 * 4 + 2] = +c
        
        self.init(array: values)
    }//initialize
    
    public init(rotate angle:CGFloat, aboutX xValue:CGFloat, y yValue:CGFloat, z zValue:CGFloat) {
        
        self.init(rotate: angle, about: SCVector3(xValue: xValue, yValue: yValue, zValue: zValue))
        /*
        values[0 * 4 + 0] = x * x * f + c
        values[1 * 4 + 0] = x * y * f - z * c
        values[2 * 4 + 0] = x * z * f + y * s
        
        values[0 * 4 + 1] = y * x * f + z * s
        values[1 * 4 + 1] = y * y * f + c
        values[2 * 4 + 1] = y * z * f - x * s
        
        values[0 * 4 + 2] = x * z * f + y * s
        values[1 * 4 + 2] = y * z * f + x * s
        values[2 * 4 + 2] = z * z * f + c
        */
    }
    
    //Projections
    public init(right:CGFloat, top:CGFloat, back:CGFloat = -1.0, front:CGFloat = 1.0) {
        
        var array:[GLfloat] =   [1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0]
        
        let left:CGFloat = 0.0
        let bottom:CGFloat = 0.0
        
        //Scale
        array[4 * 0 + 0] = GLfloat(2.0 / right)                         //x
        array[4 * 1 + 1] = GLfloat(2.0 / top)                           //y
        array[4 * 2 + 2] = GLfloat(-1.0 / (front - back))               //z
        
        //Translation
        array[4 * 3 + 0] = GLfloat(-(right + left) / (right - left))    //x
        array[4 * 3 + 1] = GLfloat(-(top + bottom) / (top - bottom))    //y
        array[4 * 3 + 2] = GLfloat(back / (front - back))               //z
        
        /*  NOTE: OpenGL might use different notation
        *  Z-Scale:
        *  -2.0 / (front - back)
        *
        *  Z-Translation:
        *  -(front + back) / (front - back)
        */
        
        
        self.init(array:array)
    }//ortho projection
    
    
    public static func perspective(angle:CGFloat, aspect:CGFloat, near:CGFloat, far:CGFloat) -> SCMatrix4 {
        
        let scale:CGFloat = tan(angle / 2.0) * near
        let right:CGFloat = aspect * scale
        let left = -right
        let top:CGFloat = scale
        let bottom = -top
        
        return SCMatrix4.frustum(left, right:right, bottom:bottom, top:top, near:near, far:far)
        /*
        var values:[GLfloat] = [0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
        0.0, 0.0, 0.0, 0.0]
        
        values[0 * 4 + 0] = GLfloat(scale * aspect)
        values[1 * 4 + 1] = GLfloat(scale)
        values[2 * 4 + 2] = GLfloat((far + near) / (far - near))
        values[3 * 4 + 2] = GLfloat((2.0 * far * near) / (far - near))
        
        return SCMatrix4(array: values)
        */
    }//perspective projection
    
    public static func frustum(left:CGFloat, right:CGFloat, bottom:CGFloat, top:CGFloat, near:CGFloat, far:CGFloat) -> SCMatrix4 {
        
        var array:[GLfloat] =   [0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0]
        
        array[4 * 0 + 0] = GLfloat(2.0 * near / (right - left))
        array[4 * 1 + 1] = GLfloat(2.0 * near / (top - bottom))
        array[4 * 2 + 0] = GLfloat((right + left) / (right - left))
        array[4 * 2 + 1] = GLfloat((top + bottom) / (top - bottom))
        array[4 * 2 + 2] = GLfloat(-(far + near) / (far - near))
        array[4 * 2 + 3] = GLfloat(-1.0)
        array[4 * 3 + 2] = GLfloat(-2.0 * far * near / (far - near))
        
        return SCMatrix4(array:array)
    }//frustum matrix
    
    
    
    
    subscript(index:Int) -> CGFloat? {
        
        if (index < 0 || index >= values.count) {
            return nil
        }//invalid index
        
        return CGFloat(values[index])
        
    }//subscript
    
    //CustomStringConvertible Protocol
    public var description:String {
        
        get {
            
            var descriptStr = "{"
            
            for iii in 0..<16 {
                descriptStr += "\(values[iii]),"
                
                if (iii % 4 == 3) {
                    descriptStr += "\n"
                }//ready for new line
                else {
                    descriptStr += "\t"
                }//ready for tab
                
            }//add indices
            
            return descriptStr + "}"
        }//get description
        
    }//description
    
}//4x4 matrix


public func *(left:SCMatrix4, right:SCMatrix4) -> SCMatrix4 {
    
    var vals:[Float] = [1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0]
    let m1 = left.values as [Float]
    let m2 = right.values as [Float]
    cblas_sgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, Int32(4), Int32(4), Int32(4), Float(1.0), m1, Int32(4), m2, Int32(4), Float(0.0), &vals, Int32(4))
    
    return SCMatrix4(array: vals)
}//multiply matrices

public func *=(inout left:SCMatrix4, right:SCMatrix4) {
    left = left * right
}//assign and multiply matrices

public func *(left:SCMatrix4, right:SCVector4) -> SCVector4 {
    
    let rVals = [Float(right.x), Float(right.y), Float(right.z), Float(right.w)]
    var values:[Float] = [0.0, 0.0, 0.0, 1.0]
    cblas_sgemv(CblasColMajor, CblasNoTrans, 4, 4, 1.0, left.values, 4, rVals, 1, 1.0, &values, 1)
    return SCVector4(xValue: CGFloat(values[0]), yValue: CGFloat(values[1]), zValue: CGFloat(values[2]), wValue: CGFloat(values[3]))
    /*
    
    let x = left.getColumn(0)!.dot(right)
    let y = left.getColumn(1)!.dot(right)
    let z = left.getColumn(2)!.dot(right)
    let w = left.getColumn(3)!.dot(right)
    
    return SCVector4(xValue: x, yValue: y, zValue: z, wValue: w)
    */
}//multiply matrix and vector

//Uses and returns only 3-D components
public func *(left:SCMatrix4, right:SCVector3) -> SCVector3 {
    
    let vec4 = left * SCVector4(vector3: right)
    
    return SCVector3(xValue: vec4.x, yValue: vec4.y, zValue: vec4.z)
}//multiply matrix and 3-D vector

//Uses and returns only 2-D components (ignores z-values)
public func *(left:SCMatrix4, right:CGPoint) -> CGPoint {
     let vector = SCVector4(xValue: right.x, yValue: right.y, zValue: 0.0, wValue: 1.0)
    
    let transformedVector = left * vector
    
    return CGPoint(x: transformedVector.x, y: transformedVector.y)
}//multiply matrix and 2-D point

//I don't define SCVector4 * SCMatrix4 because
//it is impossible to compute 4x1 * 4x4
//However, I do allow SCVector *= SCMatrix4
//because there is no other way to do assign it
public func *=(inout left:SCVector4, right:SCMatrix4) {
    left = right * left
}//assign and multiply matrix and vector

//Same as { SCVector4 * SCMatrix4 }, except with 3-D point
public func *=(inout left:SCVector3, right:SCMatrix4) {
    
    left = right * left
    
}//assign and multiply matrix and 3-D point

//Same as { SCVector4 * SCMatrix4 }, except with 2-D point
public func *=(inout left:CGPoint, right:SCMatrix4) {
    left = right * left
}//assign and multiply matrix and 2-D point