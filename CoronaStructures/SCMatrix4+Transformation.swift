//
//  SCMatrix4+Transformation.swift
//  MatTest
//
//  Created by Cooper Knaak on 2/1/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import Foundation
import Accelerate

//SCMatrix4 + Transformation
//I had so many various ways to transform
//a matrix that I split the implementations
public extension SCMatrix4 {
    
    //Functions
    public func getRow(rowIndex:Int) -> SCVector4? {
        if (rowIndex < 0 || rowIndex > 3) {
            return nil
        }//invalid row
        
        let index = rowIndex * 4
        return SCVector4(xValue: CGFloat(values[index]), yValue: CGFloat(values[index + 1]), zValue: CGFloat(values[index + 2]), wValue: CGFloat(values[index + 3]))
    }//get row
    
    public func getColumn(columnIndex:Int) -> SCVector4? {
        if (columnIndex < 0 || columnIndex > 3) {
            return nil
        }//invalid column
        
        return SCVector4(xValue: CGFloat(values[columnIndex]), yValue: CGFloat(values[columnIndex + 4]), zValue: CGFloat(values[columnIndex + 8]), wValue: CGFloat(values[columnIndex + 12]))
    }//get column
    
    public func getRotation() -> Rotation {
        
        /*
         *  Number indices of (3x3) matrix as A-I
         *  Equate to eqution for determining them in SCMatrix4(rotate:, about:)
         *  Since rotation takes a unit vector, X^2 + Y^2 + Z^2 = 1
         *  Add the A, E, I equations, which will simplify out the
         *  X^2, Y^2, Z^2 terms. Solve for theta (angle).
         *  Equate A, E, I to correct equations and plug in theta (angle).
         *  
         *  ø = arccos((A + E + I - 1) / 2)
         *  X = √( (A - cos(theta)) / (1 - cos(theta)) )
         *  Y = √( (E - cos(theta)) / (1 - cos(theta)) )
         *  Z = √( (I - cos(theta)) / (1 - cos(theta)) )
         *
         *  If theta (angle) == 0, then you cannot solve for X, Y, Z because
         *  the denominator becomes 0. However, a rotation with an angle
         *  of 0 is just the identity matrix, and the rotation vector
         *  doesn't matter. I just return SCVector3.k
         */
        let a = self[0 * 4 + 0]!
        let e = self[1 * 4 + 1]!
        let i = self[2 * 4 + 2]!
        
        //Since I get the cosine of the angle, and the
        //angle is just the inverse cosine, I store
        //the real cosine so I don't have to compute
        //expensive calls twice
        let c = (a + e + i - 1.0) / 2.0
        let angle = acos(c)
        
        if (angle ~= 0.0) {
            //Can't solve for X, Y, Z if angle == 0,
            //but rotation w/ angle == 0 is identity matrix,
            //so rotation vector doesn't matter
            
            return (0.0, SCVector3.k)
        }
        
        //If the 'factor' is < 0, then the corresponding
        //component should also be < 0. However, you can't compute
        //the sqrt of a negative number, so I invert the sqrt of
        //the positive number
        var xFactor = (a - c) / (1.0 - c)
        var yFactor = (e - c) / (1.0 - c)
        var zFactor = (i - c) / (1.0 - c)
        var xSign:CGFloat = 1.0
        var ySign:CGFloat = 1.0
        var zSign:CGFloat = 1.0
        
        if (xFactor < 0.0) {
            xFactor *= -1.0
            xSign = -1.0
        }
        if (yFactor < 0.0) {
            yFactor *= -1.0
            ySign = -1.0
        }
        if (zFactor < 0.0) {
            zFactor *= -1.0
            zSign = -1.0
        }
        
        
        let x = sqrt(xFactor) * xSign
        let y = sqrt(yFactor) * ySign
        let z = sqrt(zFactor) * zSign
        
        return (angle, SCVector3(xValue: x, yValue: y, zValue: z))
    }//get rotation from matrix
    
    
    //Operations
    public func translateBy(vector:SCVector3) -> SCMatrix4 {
        return self.translateByX(vector.x, byY: vector.y, byZ: vector.z)
    }//translate by
    
    public func translateByX(byX:CGFloat, byY:CGFloat, byZ:CGFloat = 0.0) -> SCMatrix4 {
        return self * SCMatrix4(x: byX, y: byY, z: byZ)
    }//translate
    
    public func scaleByX(byX:CGFloat, byY:CGFloat, byZ:CGFloat = 1.0) -> SCMatrix4 {
        return self * SCMatrix4(scaleX: byX, scaleY: byY, scaleZ: byZ)
    }//scale
    
    public func rotate2D(byTheta:CGFloat) -> SCMatrix4 {
        return self * SCMatrix4(rotation2D: byTheta)
    }//rotate (2D)
    
    public func rotate(angle:CGFloat, about:SCVector3) -> SCMatrix4 {
        
        return self * SCMatrix4(rotate: angle, about: about)
        
    }//rotate
    
    public func rotate(rotation:Rotation) -> SCMatrix4 {
        
        return self.rotate(rotation.angle, about: rotation.vector)
        
    }//rotate
    
    public func rotate(rotations:TwoStepRotation) -> SCMatrix4 {
        
        if let second = rotations.second {
            
            return self.rotate(rotations.first).rotate(second)
            
        } else {
            
            return self.rotate(rotations.first)
            
        }
        
    }//rotate
    
    public func transpose() -> SCMatrix4 {

        var array:[Float] = [   1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0]
        let identityMatrix:[Float] = [  1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0]
        cblas_sgemm(CblasRowMajor, CblasTrans, CblasNoTrans, Int32(4), Int32(4), Int32(4), Float(1.0), self.values as [Float], Int32(4), identityMatrix, Int32(4), Float(0.0), &array, Int32(4))

        return SCMatrix4(array:array)
        
    }//transpose
    
    public func inverse() -> SCMatrix4 {
        
        var values:[Double] = []
        for cur in self.values {
            values.append(Double(cur))
        }
        var N:__CLPK_integer = 4
        var pivots:[__CLPK_integer] = [0, 0, 0, 0]
        var workspace:[Double] = [0, 0, 0, 0]
        var error:__CLPK_integer = 0
        
        dgetrf_(&N, &N, &values, &N, &pivots, &error)
        dgetri_(&N, &values, &N, &pivots, &workspace, &N, &error)
        
        var glValues:[GLfloat] = []
        for cur in values {
            glValues.append(GLfloat(cur))
        }
        return SCMatrix4(array: glValues)
    }//inverse matrix
    
    public func invertAndTranpose() -> SCMatrix4 {
        return self.inverse().transpose()
    }
    
    //Returns a 3x3 matrix
    public func invertTranspose3() -> [GLfloat] {
        
        var values:[Double] = []
        for jjj in 0..<3 {
            for iii in 0..<3 {
                //Multiply by 4 not 3 because I am indexing
                //original array of 4x4 matrix
                let index = jjj * 4 + iii
                values.append(Double(self.values[index]))
            }
        }
        
        var N:__CLPK_integer = 3
        var pivots:[__CLPK_integer] = [0, 0, 0]
        var workspace:[Double] = [0, 0, 0]
        var error:__CLPK_integer = 0
        
        dgetrf_(&N, &N, &values, &N, &pivots, &error)
        dgetri_(&N, &values, &N, &pivots, &workspace, &N, &error)
        
        var glValues:[GLfloat] = []
        for jjj in 0..<3 {
            for iii in 0..<3 {
                //I do it backwards to convert the values
                //into the transposed matrix
                let index = iii * 3 + jjj
                glValues.append(GLfloat(values[index]))
            }
        }
        
        
        return glValues
    }
    
}//Transformation
