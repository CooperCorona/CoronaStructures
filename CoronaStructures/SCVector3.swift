//
//  SCVector3.swift
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

public struct SCVector3: CustomStringConvertible {
    
    // MARK: - Properties
    
    public var x:CGFloat
    public var y:CGFloat
    public var z:CGFloat
    
    public var r:CGFloat {
        
        get {
            return x
        }
        
    }//r
    
    public var g:CGFloat {
        
        get {
            return y
        }
        
    }//g
    
    public var b:CGFloat {
        
        get {
            return z
        }
        
    }//b
    
    public var isZero:Bool {
        return self.x ~= 0.0 && self.y ~= 0.0 && self.z ~= 0.0
    }
    
    // MARK: - Setup
    
    //Initialization
    public init(xValue:CGFloat, yValue:CGFloat, zValue:CGFloat) {
        x = xValue
        y = yValue
        z = zValue
    }//initialize
    
    public init(x:CGFloat, y:CGFloat, z:CGFloat) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    public init(values:(CGFloat, CGFloat, CGFloat)) {
        self.init(xValue: values.0, yValue: values.1, zValue: values.2)
    }//initialize
    
    public init(glTuple:(x:GLfloat, y:GLfloat, z:GLfloat)) {
        
        self.init(xValue: CGFloat(glTuple.x), yValue: CGFloat(glTuple.y), zValue: CGFloat(glTuple.z))
        
    }//initialize
    
    public init(string:String) {
        
        let comps = (string as String).componentsSeparatedByString(", ")
        if (comps.count >= 3) {
            
            let x = comps[0].getCGFloatValue() ?? 0.0
            let y = comps[1].getCGFloatValue() ?? 0.0
            let z = comps[2].getCGFloatValue() ?? 0.0
            
            self.init(xValue: CGFloat(x), yValue: CGFloat(y), zValue: CGFloat(z))
            
        } else {
            
            self.init()
        }
        
    }//initialize with a string
    
    public init() {
        self.init(xValue: 0.0, yValue: 0.0, zValue: 0.0)
    }//initialize
    
    
    
    public static var i:SCVector3 { return SCVector3(xValue: 1.0, yValue: 0.0, zValue: 0.0) }
    public static var j:SCVector3 { return SCVector3(xValue: 0.0, yValue: 1.0, zValue: 0.0) }
    public static var k:SCVector3 { return SCVector3(xValue: 0.0, yValue: 0.0, zValue: 1.0) }
    
    // MARK: - Logic
    
    //Vector Functions
    public func length() -> CGFloat {
        return sqrt(x * x + y * y + z * z)
    }//get length
    
    public func normalize() -> SCVector3 {
        let l = length()
        return SCVector3(xValue: x / l, yValue: y / l, zValue: z / l)
    }//get normalized vector
    
    public func dot(dotBy:SCVector3) -> CGFloat {
        return x * dotBy.x + y * dotBy.y + z * dotBy.z
    }//compute the dot product
    
    public func cross(crossBy:SCVector3) -> SCVector3 {
        return SCVector3(xValue: y * crossBy.z - z * crossBy.y, yValue: z * crossBy.x - x * crossBy.z, zValue: x * crossBy.y - y * crossBy.x)
    }
    
    //Computes self - self.dot(direction) * direction
    //That removes the components in 'direction'
    public func removeComponentsInDirection(direction:SCVector3) -> SCVector3 {
        return self - self.dot(direction) * direction
    }//remove components of self in directoin
    
    public func angleBetween(vector:SCVector3) -> CGFloat {
        let sLength = self.length()
        let vLength = vector.length()
        
        if (sLength <= 0.001 || vLength <= 0.001) {
            return 0.0
        }
        
        return acos(self.dot(vector) / sLength / vLength)
    }//get angle between self and vector
    
    public func distanceTo(vector:SCVector3) -> CGFloat {
        return (self - vector).length()
    }
    
    //Finds the nearest point in 'points'
    //to self
    public func findNearestPoint(points:[SCVector3]) -> SCVector3 {
        
        if (points.count <= 0) {
            return self
        }
        
        var currentPoint = points[0]
        var currentDistance = self.distanceTo(points[0])
        
        for iii in 1..<points.count {
            
            let curDist = self.distanceTo(points[iii])
            if (curDist < currentDistance) {
                currentPoint = points[iii]
                currentDistance = curDist
            }
        }
        
        return currentPoint
    }//find the nearest point
    
    //Gets unit vector parallel to this vector
    //If this vector is <0, 0, 0>, then returns
    //unit vector ^k
    public func unit() -> SCVector3 {
        
        let l = self.length()
        if (l == 0.0) {
            return SCVector3(xValue: 0.0, yValue: 0.0, zValue: 1.0)
        } else {
            return self / l
        }
        
    }//unit vector
    
    public func getTuple() -> (CGFloat, CGFloat, CGFloat) {
        return (x, y, z)
    }//get vector as tuple
    
    public func getGLTuple() -> (GLfloat, GLfloat, GLfloat) {
        return (GLfloat(x), GLfloat(y), GLfloat(z))
    }//get vector as GLfloat tuple
    
    public func getGLTuple4(w:CGFloat = 1.0) -> (GLfloat, GLfloat, GLfloat, GLfloat) {
        return (GLfloat(self.x), GLfloat(self.y), GLfloat(self.z), GLfloat(w))
    }
    
    ///Array has count == 3
    func getArray() -> [CGFloat] {
        return [self.r, self.g, self.b]
    }
    
    ///Array has count == 3
    func getGLArray() -> [GLfloat] {
        return [GLfloat(self.r), GLfloat(self.g), GLfloat(self.b)]
    }
    
    
    public func closeToZero(epsilon:CGFloat) -> Bool {
        
        return abs(self.x) <= epsilon && abs(self.y) <= epsilon && abs(self.z) <= epsilon
        
    }//too close to zero?
    
    //CustomStringConvertible Protocol
    public var description:String {
        
        get {
            return "{\(x), \(y), \(z)}"
        }
        
    }
    
}

// MARK: - OpenGL
extension SCVector3 {
    
    public func bindGLClearColor() {
        glClearColor(GLfloat(self.x), GLfloat(self.y), GLfloat(self.z), 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    }
    
    public func getGLComponents() -> [GLfloat] {
        return [GLfloat(self.x), GLfloat(self.y), GLfloat(self.z)]
    }
    
}



//Operations
public func +(left:SCVector3, right:SCVector3) -> SCVector3 {
    return SCVector3(xValue: left.x + right.x, yValue: left.y + right.y, zValue: left.z + right.z)
}//plus

public func -(left:SCVector3, right:SCVector3) -> SCVector3 {
    return SCVector3(xValue: left.x - right.x, yValue: left.y - right.y, zValue: left.z - right.z)
}//minus

public func *(left:SCVector3, right:SCVector3) -> SCVector3 {
    return SCVector3(xValue: left.x * right.x, yValue: left.y * right.y, zValue: left.z * right.z)
}//times

public func /(left:SCVector3, right:SCVector3) -> SCVector3 {
    return SCVector3(xValue: left.x / right.x, yValue: left.y / right.y, zValue: left.z / right.z)
}//divide

prefix func -(unary:SCVector3) -> SCVector3 {
    
    return SCVector3(xValue: -unary.x, yValue: -unary.y, zValue: -unary.z)
    
}//negate

//Equals
public func +=(inout left:SCVector3, right:SCVector3) {
    left = left + right
}//plus

public func -=(inout left:SCVector3, right:SCVector3) {
    left = left - right
}//minus

public func *=(inout left:SCVector3, right:SCVector3) {
    left = left * right
}//times

public func /=(inout left:SCVector3, right:SCVector3) {
    left = left / right
}//divide


//Scalar
public func +(left:SCVector3, right:CGFloat) -> SCVector3 {
    return SCVector3(xValue: left.x + right, yValue: left.y + right, zValue: left.z + right)
}//plus

public func -(left:SCVector3, right:CGFloat) -> SCVector3 {
    return SCVector3(xValue: left.x - right, yValue: left.y - right, zValue: left.z - right)
}//minus

public func *(left:SCVector3, right:CGFloat) -> SCVector3 {
    return SCVector3(xValue: left.x * right, yValue: left.y * right, zValue: left.z * right)
}//times

public func /(left:SCVector3, right:CGFloat) -> SCVector3 {
    return SCVector3(xValue: left.x / right, yValue: left.y / right, zValue: left.z / right)
}//divide

public func +(left:CGFloat, right:SCVector3) -> SCVector3 {
    return SCVector3(xValue: left + right.x, yValue: left + right.y, zValue: left + right.z)
}//plus

public func -(left:CGFloat, right:SCVector3) -> SCVector3 {
    return SCVector3(xValue: left - right.x, yValue: left - right.y, zValue: left - right.z)
}//minus

public func *(left:CGFloat, right:SCVector3) -> SCVector3 {
    return SCVector3(xValue: left * right.x, yValue: left * right.y, zValue: left * right.z)
}//times

public func /(left:CGFloat, right:SCVector3) -> SCVector3 {
    return SCVector3(xValue: left / right.x, yValue: left / right.y, zValue: left / right.z)
}//divide


//Scalar Equals
public func +=(inout left:SCVector3, right:CGFloat) {
    left = left + right
}//plus

public func -=(inout left:SCVector3, right:CGFloat) {
    left = left - right
}//minus

public func *=(inout left:SCVector3, right:CGFloat) {
    left = left * right
}//times

public func /=(inout left:SCVector3, right:CGFloat) {
    left = left / right
}//divide

//Custom


public func ~=(left:SCVector3, right:SCVector3) -> Bool {
    
//    let epsilon:CGFloat = 0.001
    
    return  left.x ~= right.x &&
        left.y ~= right.y &&
        left.z ~= right.z
}//about equals operator

